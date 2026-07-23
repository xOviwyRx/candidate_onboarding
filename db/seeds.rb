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

# The Dutch spellings are what the CV parser matches on: §5 asks for Dutch and
# English CVs, and the seeded name is only ever the English one.
{
  "Endodontics" => [ DENTISTS, %w[endodontie] ],
  "Restorative dentistry" => [ DENTISTS, [ "restauratieve tandheelkunde" ] ],
  "Pediatric dentistry" => [ DENTISTS, %w[kindertandheelkunde] ],
  "Surgery" => [ DENTISTS, %w[chirurgie] ],
  "Aligners" => [ DENTISTS, %w[beugels] ],
  "Periodontology" => [ [ "dental_hygienist" ], %w[parodontologie paro] ],
  "Scaling" => [ [ "dental_hygienist" ], %w[gebitsreiniging] ],
  "Patient education" => [ [ "dental_hygienist" ], %w[voorlichting patiëntenvoorlichting] ],
  "Prevention" => [ [ "dental_hygienist", *ASSISTANTS ], %w[preventie] ],
  "Chairside assistance" => [ ASSISTANTS, %w[stoelassistentie assisteren] ],
  "Sterilization" => [ ASSISTANTS, %w[sterilisatie steriliseren] ],
  "Orthodontics" => [ ASSISTANTS, %w[orthodontie] ],
  "Planning" => [ [ "front_office" ], %w[agendabeheer planning] ],
  "Phone handling" => [ [ "front_office" ], %w[telefonie] ],
  "Invoicing" => [ [ "front_office" ], %w[facturatie declaraties] ],
  "Patient communication" => [ [ "front_office" ], %w[patiëntencommunicatie] ],
  "Team management" => [ [ "practice_manager" ], %w[teammanagement leidinggeven] ],
  "Scheduling" => [ [ "practice_manager" ], %w[roosteren personeelsplanning] ],
  "HR" => [ [ "practice_manager" ], %w[personeelszaken] ],
  "Practice operations" => [ [ "practice_manager" ], %w[praktijkvoering] ],
  "Prosthetics" => [ [ "dental_technician" ], %w[prothetiek] ],
  "CAD/CAM" => [ [ "dental_technician" ], %w[cadcam] ],
  "Crown and bridge work" => [ [ "dental_technician" ], [ "kroon- en brugwerk" ] ]
}.each do |name, (job_functions, synonyms)|
  # find_or_initialize rather than find_or_create_by!, whose block only runs on
  # create: re-seeding has to update rows that already exist, not skip them.
  skill = Skill.find_or_initialize_by(name: name)
  skill.job_functions = job_functions
  skill.synonyms = synonyms
  skill.save!
end
