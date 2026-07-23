# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# A candidate to sign in with while developing. On the real platform, accounts
# already exist and this onboarding module inherits the signed-in user.
User.find_or_create_by!(email: "candidate@example.com") do |user|
  user.password = "secret123"
end

# The platform's language list. Candidates pick from these rather than typing,
# so the same language always matches across profiles.
%w[
  Dutch English German French Spanish Italian
  Portuguese Polish Romanian Turkish Arabic Ukrainian Russian
].each { |name| Language.find_or_create_by!(name: name) }

# §3.6's skill groups. A skill can belong to more than one function: prevention
# is listed under both the hygienist and the assistant.
DENTISTS = %w[general_dentist specialist].freeze
ASSISTANTS = %w[dental_assistant prevention_assistant paro_prevention_assistant orthodontic_assistant].freeze

{
  "Endodontics" => DENTISTS,
  "Restorative dentistry" => DENTISTS,
  "Pediatric dentistry" => DENTISTS,
  "Surgery" => DENTISTS,
  "Aligners" => DENTISTS,
  "Periodontology" => [ "dental_hygienist" ],
  "Scaling" => [ "dental_hygienist" ],
  "Patient education" => [ "dental_hygienist" ],
  "Prevention" => [ "dental_hygienist", *ASSISTANTS ],
  "Chairside assistance" => ASSISTANTS,
  "Sterilization" => ASSISTANTS,
  "Orthodontics" => ASSISTANTS,
  "Planning" => [ "front_office" ],
  "Phone handling" => [ "front_office" ],
  "Invoicing" => [ "front_office" ],
  "Patient communication" => [ "front_office" ],
  "Team management" => [ "practice_manager" ],
  "Scheduling" => [ "practice_manager" ],
  "HR" => [ "practice_manager" ],
  "Practice operations" => [ "practice_manager" ],
  "Prosthetics" => [ "dental_technician" ],
  "CAD/CAM" => [ "dental_technician" ],
  "Crown and bridge work" => [ "dental_technician" ]
}.each do |name, job_functions|
  Skill.find_or_create_by!(name: name) { |skill| skill.job_functions = job_functions }
end
