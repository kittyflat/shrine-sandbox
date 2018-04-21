# B2 Storage
#
# Creating a New Storage: http://shrinerb.com/rdoc/files/doc/creating_storages_md.html
# S3 Storage: https://github.com/shrinerb/shrine/blob/master/lib/shrine/storage/s3.rb
#
require 'http'
require 'down'
require 'down/http'

class Shrine
  module Storage
    class B2
      attr_reader :client, :bucket, :prefix #, :host, :upload_options

      def initialize(account_id:, application_key:, bucket_name:, bucket_id:, prefix: nil)
        @account_id = account_id
        @application_key = application_key
        @bucket_name = bucket_name
        @bucket_id = bucket_id
        @client = nil
        @prefix = prefix
        authorize
      end

      def authorize
        # TODO
        # should try to cache account authorizations
        # b2_authorize_account is a Class C transaction (costs more)
        #
        @api_path = "/b2api/v1/"
        resp = HTTP.basic_auth(:user => @account_id, :pass => @application_key)
          .get("https://api.backblazeb2.com#{@api_path}b2_authorize_account")
        raise unless resp.code == 200
        json = JSON.parse(resp.to_s)
        @account_authorization_token = json['authorizationToken']
        @api_url = json['apiUrl']
        @download_url = json['downloadUrl']
      end

			def upload(io, id, shrine_metadata: {}, **upload_options)
				# uploads `io` to the location `id`, can accept upload options
        resp = HTTP.auth(@account_authorization_token)
          .post("#{@api_url}#{@api_path}b2_get_upload_url", json: { bucketId: @bucket_id })
        raise unless resp.code == 200
        json = JSON.parse(resp.to_s)
        upload_url = json['uploadUrl']
        upload_authorization_token = json['authorizationToken']

        # TODO
        # "picky rules" on file names
        # large files
        # mime types/content disposition?
        #
        # https://www.backblaze.com/b2/docs/files.html
        #
        file_name = [*prefix, id].join('/').tr_s('/', '/').sub(/\A\//, '')

        # Rails.logger.info "io.class: #{io.class}"
        # if io.respond_to?(:storage)
        #   Rails.logger.info "io.storage: #{io.storage.inspect}"
        # else
        #   Rails.logger.info "no storage class"
        # end
        file_path = if io.respond_to?(:path)
                      # Rails.logger.info "io.path: #{io.path}"
                      io.path
                    elsif io.is_a?(UploadedFile) && defined?(Storage::FileSystem) && io.storage.is_a?(Storage::FileSystem)
                      # Rails.logger.info "io.storage.path: #{io.storage.path(io.id).to_s}"
                      io.storage.path(io.id).to_s
                      # io.path
                    end
        # XXX
        # if the cache storage is also B2, then the file_path will be
        # empty. Instead, the file needs to be first downloaded, then
        # re-uploaded to the store.
        # Because of this inefficiency and lack of a copy API, we are
        # currently using FileSystem as the cache store to save an extra
        # download/re-upload to promote cache to store

        # Rails.logger.info "file_path: #{file_path}"

        headers = {
          'X-Bz-File-Name': file_name,
          'Content-Type': 'b2/x-auto',
          'Content-Length': io.size,
          'X-Bz-Content-Sha1': Digest::SHA1.new.file(file_path).hexdigest
        }
        resp = HTTP.auth(upload_authorization_token)
          .headers(headers)
          .post(upload_url, body: io)
        raise unless resp.code == 200
        json = JSON.parse(resp.to_s)
        file_id = json['fileId']
        id.replace("#{file_id}:#{file_name}")
			end

      # Store `id` as file_id:location
      # #identifier returns the part required from `id`
      #
      def identifier(identifier, part)
        id, location = identifier.split(":", 2)
        { id: id, location: location }[part]
      end

			def url(id, **options)
				# returns URL to the remote file, accepts options for customizing the URL
        "#{@download_url}/file/#{@bucket_name}/#{identifier(id, :location)}"
			end

      def download(id)
        # download the file to a Tempfile

        # Using b2_download_file_by_name
        file_url = url(id)
        tempfile = Down::Http.download(file_url)

        # Using b2_download_file_by_id
        # file_url = "#{@download_url}#{@api_path}b2_download_file_by_id"
        # tempfile = Down::Http.download(file_url, params: { fileId: identifier(id, :id) })

        tempfile
      end

			def open(id)
				# returns the remote file as an IO-like object
        file_url = url(id)
        io = Down::Http.open(file_url)
        io
			end

			def exists?(id)
				# checks if the file exists on the storage
        id = identifier(id, :id)
        resp = HTTP.auth(@account_authorization_token)
          .post("#{@api_url}#{@api_path}b2_get_file_info", json: { fileId: id })
        return false if resp.code == 404
        raise unless resp.code == 200
        json = JSON.parse(resp.to_s)
        return json['action'] == "upload"
			end

			def delete(id)
				# deletes the file from the storage
        resp = HTTP.auth(@account_authorization_token)
          .post("#{@api_url}#{@api_path}b2_delete_file_version",
                json: { fileName: identifier(id, :location),
                        fileId:   identifier(id, :id) })
			end
    end
  end
end
