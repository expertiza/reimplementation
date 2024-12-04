begin
    #Create an instritution
    Institution.create!(
      name: 'North Carolina State University',
    )
    
    # Create an admin user
    User.create!(
      name: 'admin',
      email: 'admin2@example.com',
      password: 'password123',
      full_name: 'admin admin',
      institution_id: 1,
      role_id: 1
    )

   # Execute an SQL script (init_databases.sql)
    sql_file = Rails.root.join('db', 'grant_priv.sql')
    if File.exist?(sql_file)
      sql = File.read(sql_file)
      ActiveRecord::Base.connection.execute(sql)
    else
      puts "SQL file not found: #{sql_file}"
    end

rescue ActiveRecord::RecordInvalid => e
    puts 'The db has already been seeded'
end