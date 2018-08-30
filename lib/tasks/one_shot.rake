namespace :one_shot do
  desc "Set manual mode for unsupported checks"
  task reset_checks_modes: :environment do
    Check.domain.find_each do |check|
      check.mode = if check.supported?
        :auto
      else
        :manual
      end

      check.save(validate: false)
    end
  end
end
