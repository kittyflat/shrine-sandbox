class DeleteJobWorker
  include Sidekiq::Worker

  def perform(*args)
    data = args.first
    Shrine::Attacher.delete(data)
  end
end
