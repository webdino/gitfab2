Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
log_path = Rails.env.production? ? File.join(Rails.root, 'shared', 'log', 'delayed_job.log') : File.join(Rails.root, 'log', 'delayed_job.log')
Delayed::Worker.logger = Logger.new(log_path)

if Rails.env == "development"
  class Delayed::Worker
    def handle_failed_job_with_loggin(job, error)
      handle_failed_job_without_loggin(job,error)
      Delayed::Worker.logger.error(error.message)
      Delayed::Worker.logger.error(error.backtrace.join("\n"))
    end
    alias_method_chain :handle_failed_job, :loggin
  end
end
