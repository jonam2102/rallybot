######################################################################################################################
#                                 Rally Ruby framework                                                           #####
#                                                                                                                   ##
#  Developed for personal usage to all users to create changeset and changes in Rally whenever committing in        ##
#                               
#                              
#####################################################################################################################

#! /usr/bin/evn ruby

require 'json'
require 'rally_api'
require 'pp'
require 'date'
require 'time'
require 'logger'
require_relative '00-config'

def show_results(title,results)
    log = Logger.new(STDOUT)
    log.level = Logger::INFO
    log.formatter = proc do |severity, datetime, progname,msg| 
    "#{datetime}: #{msg}\n"
    end

    log.info title
    
    results.each do |result| 
	    log.info("Formatted id = #{result.FormattedID}")
            log.info("Object ID = #{result.ObjectID}")
            log.info("Changeset ID = #{result.Changesets}")
   end

   results.total_result_count

end


def show_results_user(results)
	log = Logger.new(STDOUT)
	log.level = Logger::INFO
        log.formatter = proc do |severity, datetime, progname, msg|
	
	"#{datetime}: #{msg}\n"
        end 

	log.info "*" * 100
	format = "%30s : %30s : %30s : %30s : %30s  : %s \n"

	puts ""
	results.each do |result|
		log.info("#{result.ObjectId}")
		log.info("#{result.UserName}")
		log.info("#{result.EmailAddress}")
		log.info("#{result.DisplayName}")
		log.info("#{result._ref}")
	end

        results.total_result_count

end	

def show_results_change(results)

	log = Logger.new(STDOUT)
	log.level = Logger::INFO
        log.formatter = proc do |severity, datetime, progname, msg|
	
	"#{datetime}: #{msg}\n"
        end 

	log.info "*" * 100
	format = "%30s : %30s : %30s : %30s : %30s  : %30s :%30s : %30s : %30s : %30s\n"
	log.info(format, "ObjectID", "FormattedID", "Name", "Changesets", "Author", "Revision" , "Message" , "CommitTimestamp" "reference")

	puts ""
	results.each do |result|
		log.info("#{result.ObjectId}")
		log.info("#{result.FormattedID}")
		log.info("#{result.Name}")
		log.info("#{result.Changesets}")
		log.info("#{result.Author}")
		log.info("#{result.Revision}")
		log.info("#{result.Message}")
		log.info("#{result.CommitTimestamp}")
		log.info("#{result._ref}")
	end
end

def create_scm(my_scm_repo,my_scm_desc,my_scm_uri)
	log = Logger.new(STDOUT)
	log.level = Logger::INFO
        log.formatter = proc do |severity, datetime, progname, msg|
	
	"#{datetime}: #{msg}\n"
        end 
     
    puts "*"  * 50
    log.info(":Creating new scm repo:")

    fields = {}

    fields["Name"]   = my_scm_repo
    fields["Description"]  = my_scm_desc
    fields["Uri"]  = my_scm_uri
    fields["ScmType"]  = "gitlab_ee"

    begin
    	rally = RallyAPI::RallyRestJson.new(@config)
    	scm_repo_create - rally.create(:SCMRepository, fields)
        log.info "Successfully created the scm repo #{my_scm_repo}"


    rescue => ex 
    	log.error "Error Occurred while trying to create #{my_scm_repo}"
    	log.error ex
    	log.error ex.msg
    	log.error ex.backtrace

    end

 end


 begin

   log = Logger.new(STDOUT)
	log.level = Logger::INFO
        log.formatter = proc do |severity, datetime, progname, msg|
	
	"#{datetime}: #{msg}\n"
        end 

   filename = ARGV[1].rstrip
   file = File.read(filename)
    
   data_hash = JSON.parse(file)
   $length = data_hash.fetch("commits").length

   log.info "Commits in the push made by user #{$length}"

   rally = RallyAPI::RallyRestJson.new(@config)
   log.info "Startup of the ruby framework"

   log.info "*" * 50

   log.info "Connecting to Rally --------------"
   log.info "Rally _api version : #{RallyAPI::version}"
   log.info "Rally web services API version #{rally.wsapi_version}"
   log.info "*" * 50 

   artifact_formatted_id = ARGV[0].rstrip.upcase
   log.info "Provided artifact id #{artifact_formatted_id}"


   $my_scm_uri = data_hash.fetch("repository").fetch("git_http_url")
   log.info "The name of the scm url provided #{my_scm_uri}"

   $my_scm_desc = data_hash.fetch("repository").fetch("description")
    log.info "The description of the scm url provided #{my_scm_desc}"

   artifact_type = artifact_formatted_id[/[A-Z]+/] 
   start_number = artifact_formatted_id[/\d+/]


   # Validate the artifact provided 

     if artifact_type.nil? or start_number.nil? then 
     	  log.error "Invalid formatted id , please use format id type DE1232 : exiting"
     	  exit
     end

     start_number_int = start_number.to_i

     log.info "#{start_number_int}"

    #valid artifact types
      standard_types = ["US","DE","TC","TA"]
      valid_types = standard_types

      artifact_type_match = valid_types.include? artifact_type

      if artifact_type_match == false then 
      	log.error "Invalid formatted id provided"
      	log.error "Please use valid types of #{valid_types}"
      	exit
      end

      valid_query_types = {
      	"US" => :hierarchalrequirement,
      	"TA" => :task,
      	"DE" => :defect,
      	"TE" => :testcase,
      }
     
     query_type = valid_query_types[artifact_type]

     #Searching for valid artifact using search Rest api 

     log.info "Querying for : #{query_type}"

     query_string = "(FormattedID = #{start_number})"

     scm_repo_query = RallyAPI::RallyQuery.new()
     scm_repo_query.type = query_type
     scm_repo_query.fetch = "ObjectID,FormattedID,Name,Changesets"
     scm_repo_query.order = "FormattedID Asc"
     scm_repo_query.project_scope_down = "true"
     scm_repo_query.query_string = query_string

     artifact_query_results = rally.find(scm_repo_query)
     number_of_artifacts = artifact_query_results.total_result_count

     if number_of_artifacts == 0 then 
     	log.error "No formatted ID is found with this value"
     	log.error "Please provide valid artifact id "
     	exit

      end

      log.info "::Number of artifacts found : #{number_of_artifacts}"
      show_results(query_type,artifact_query_results)

      found_artifact - artifact_query_results.first


      puts "*" * 80

      puts "querying for scm :#{my_scm_repo}"
      
      scm_repo_query = "Name = \"#{my_scm_repo}\")"
      scm_repo_query = RallyAPI::RallyQuery.new()
      scm_repo_query.type = query_type
      scm_repo_query.fetch = "ObjectID,Name,ScmType"
      scm_repo_query.order = "CreationDate Asc"
      scm_repo_query.project_scope_down = "true"
      scm_repo_query.query_string = query_string
      
      scm_repo_results = rally.find(scm_repo_query)

      number_of_repo = scm_repo_query.total_result_count


	  if number_of_repo == 0 then 
     	log.info "No SCM Repo ID is found with this value"
     	log.info "Creating the scm repo"

     	create_scm($my_scm_repo,$my_scm_desc,$my_scm_uri)
     	log.info "Created"

     	#Research to ensure repo is created


      scm_repo_query = "Name = \"#{my_scm_repo}\")"
      scm_repo_query = RallyAPI::RallyQuery.new()
      scm_repo_query.type = query_type
      scm_repo_query.fetch = "ObjectID,Name,ScmType"
      scm_repo_query.order = "CreationDate Asc"
      scm_repo_query.project_scope_down = "true"
      scm_repo_query.query_string = query_string
      
      scm_repo_results = rally.find(scm_repo_query)

      number_of_repo = scm_repo_query.total_result_count

      log.info "Repos: found after creation #{number_of_repo}"
      changeset_scm_repo = scm_repo_results.first 


 	 else 
      log.info "#{$number_of_repo}"
      changeset_scm_repo = scm_repo_results.first

  end

  ##################################################################################################################
  #                                            Creating the changeset                                              #
  ##################################################################################################################

  log.info "Number of commits provided in this push : #{$length}"

  $i = 0 

  while $i < $length do 

  	$commit_url = data_hash.fetch("commits")[$i]["url"]
    $author = (data_hash.fetch("commits")[$i]["author"].fetch("email").rstrip)

    log.info "Running for Commit : $i"
    log.info "In commit loop starting to create the changeset"

    log.info "Looking up the author for creating the changeset"
    rally = RallyAPI::RallyRestJson.new(@config)
    user_query = RallyAPI::RallyQuery.new()
    user_query_type = "user"

    user_query.fetch = "ObjectID,UserName,EmailAddress,DisplayName"
    user_query.query_string = "(UserName = #{$author})"

    user_results = rally.find(user_query)
    show_results_user(user_results)

    changeset_author = user_results.first
    log.info "Starting the changeset create"


#puts "Please enter the changeset revision:"
#changeset_revision = [(print 'Enter revision : ').gets.rstrip][1]
# puts "Puts provided revision number : #{revision_number}"
# changeset_revision = $revision_number


$json_revision = data_hash.fetch("commits")[$i]["id"]
$json_uri = data_hash.fetch("commits")[$i]["url"]

log.info "Provided revision number : #{json_revision}"
log.info "Provided url for git changeset: #{json_url}"


$json_message = data_hash.fetch("commits")[$i]["message"]
$json_timestamp = data_hash.fetch("commits")[$i]["timestamp"]

      new_changeset = {}

      new_changeset["Author"] = changeset_author
      new_changeset["Revision"] = changeset_revision
      new_changeset["Uri"] = changeset_uri
      new_changeset["ScmRepository"] = changeset_scm_repo
      new_changeset["Message"] = changeset_message
      new_changeset["CommitTimestamp"] = changeset_timestamp
      new_changeset["Artifacts"] = [found_artifact]

      create_result = rally.create(:changeset, new_changeset)
      

      log.info "Created a changeset: #{create_result}"
      log.info "Completed"

      $changeset_x = create_result.ref


log.info "Changeset Reference : #{$changeset_x}"
	

$added = data_hash.fetch("commits")[$i].fetch("added")
$modified = data_hash.fetch("commits")[$i].fetch("modified")
$removed = data_hash.fetch("commits")[$i].fetch("removed")



# Creating 3 loops so that in future people can remove iteration of git event in case needed.

#Change create for Deletion in git commit 

if $removed.nil? || $removed.empty? then 
	log.info ("No files were deleted to create a change")

else 
	  new_change = {}
	  new_change["PathAndFilename"] = $removed
	  new_change["Uri"] = $changeset_url
	  new_change["Changeset"] = $changeset_x
	  new_change["Action"] = "Removed"
	  create_change = rally.create(:change, new_change)
	  log.info "Created a change : #{ create_change } for deletions made into the git event"
	  log.info "Completed adding change"

end


#Change create for Modifications in git commit 

if $modified.nil? || $modified.empty? then 
	log.info ("No files were modified to create a change")

else 
	  new_change = {}
	  new_change["PathAndFilename"] = $modified
	  new_change["Uri"] = $changeset_url
	  new_change["Changeset"] = $changeset_x
	  new_change["Action"] = "Modified"
	  create_change = rally.create(:change, new_change)
	  log.info "Created a change : #{ create_change } for modifications made into the git event"
	  log.info "Completed adding change"

end



#Change create for added in git commit 

if $added.nil? || $added.empty? then 
	log.info ("No files were added to create a change")

else 
	  new_change = {}
	  new_change["PathAndFilename"] = $added
	  new_change["Uri"] = $changeset_url
	  new_change["Changeset"] = $changeset_x
	  new_change["Action"] = "Added"
	  create_change = rally.create(:change, new_change)
	  log.info "Created a change : #{ create_change } for additions made into the git event"
	  log.info "Completed adding change"

end


$i +=1

end

rescue Exception=>boom
 log.info "Rescused #{boom.class}"
 log.info "Error Message #{boom}" 

end