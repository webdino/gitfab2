Rails.application.config.assets.configure do |env|
  Sprockets::Commoner::Processor.configure(env,
   include: ['app/assets/javascripts'],
  )
end
