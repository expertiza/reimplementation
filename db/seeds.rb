#Thisfileshouldcontainalltherecordcreationneededtoseedthedatabasewithitsdefaultvalues.

#Thedatacanthenbeloadedwiththebin/railsdb:seedcommand(orcreatedalongsidethedatabasewithdb:setup).

#

#Examples:

#

#movies=Movie.create([{name:"StarWars"},{name:"LordoftheRings"}])

#Character.create(name:"Luke",movie:movies.first)



institution1=Institution.create!(

  name:'Purdue'

)



admin=User.create!(

  name:'admin',

  password_digest:BCrypt::Password.create('admin'),#Hashedpassword

  full_name:'JohnA.Doe',

  email:'john.doe@example.com',

  mru_directory_path:'/path/to/directory',

  email_on_review:true,

  email_on_submission:false,

  email_on_review_of_review:true,

  is_new_user:true,

  master_permission_granted:false,

  handle:'johndoe',

  persistence_token:'token123',

  timeZonePref:'UTC',

  copy_of_emails:false,

  etc_icons_on_homepage:true,

  locale:1,

  role_id:2,

  institution:institution1,

  )



instructor1=User.create!(

  name:'instructora',

  password_digest:BCrypt::Password.create('password'),#Hashedpassword

  full_name:'JohnA.Doe',

  email:'instructor.ins@example.com',

  mru_directory_path:'/path/to/directory',

  email_on_review:true,

  email_on_submission:false,

  email_on_review_of_review:true,

  is_new_user:true,

  master_permission_granted:false,

  handle:'instruct',

  persistence_token:'token123',

  timeZonePref:'UTC',

  copy_of_emails:false,

  etc_icons_on_homepage:true,

  locale:1,

  role_id:3,

  institution:institution1,

  )



course=Course.create!(

  name:'IntroductiontoProgramming',

  directory_path:'/programming101',

  info:'Thisisanintroductorycourseonprogramming.',

  private:false,

  instructor:instructor1,

  institution:institution1

)



