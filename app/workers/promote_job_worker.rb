class PromoteJobWorker
  include Sidekiq::Worker

  def perform(*args)
    data = args.first
    Shrine::Attacher.promote(data)
  end
end
