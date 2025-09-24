puts "Seeding admin user..."

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.username = "admin"
  u.password = "Password1!"
  u.password_confirmation = "Password1!"
  u.role = :admin
  u.confirmed_at = Time.current  # skip confirmable for seed
  u.approval_date = Time.current   # mark approved immediately
end

puts "Admin user ready: #{admin.email} / Password1!"
