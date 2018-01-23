job_type :envcommand, 'cd :path && RAILS_ENV=:environment :task'

# Ensure our background processor starts up on reboot (10 processes)
every :reboot do
  envcommand 'bin/delayed_job -n 1 -p roles restart'
end

every 24.hours do
  rake 'dw:import_pps_departments'
  rake 'iam:import_sis_majors'
  rake 'iam:import_bous'
end

# Sync with external systems
every 12.hours do
  rake 'dw:import'
  rake 'person:mark_inactive'
  rake 'person:remove_inactive'
end

every 30.minutes do
  rake 'ad:resync_roles'
end
