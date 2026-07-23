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
  Portuguese Polish Romanian Turkish Arabic Ukrainian
].each { |name| Language.find_or_create_by!(name: name) }
