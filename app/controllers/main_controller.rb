require 'open-uri'
require 'json'


class MainController < ApplicationController
  include BCrypt
  skip_before_filter :verify_authenticity_token
  @@id = nil
  @@applied_Departments={}
  @@universities=nil
  @@user_type = nil
  @@location = nil
  def initialize
    super
    @student = Student
    @profiles = Profile
    @faculty = Faculty
    @current_profile = nil
    @id = @@id
    @user_type = @@user_type
    @location = @@location
    @applications= Application

  end
  def index

  end
  def login
    @student = Student
    @profiles = Profile
  end
  def intermediate_logout
    @@id = nil
    redirect_to root_path
  end
  def sign_up
    @profiles = Profile
    @profiles.all.each do |p|
      puts p.id
    end
  end
  def view_profile

    @current_profile = Profile.where(student_id: @@id).take
    #@experience = Experience.where(student_id: @id).take
    puts @@id,"View"

    @student = Student.find(@@id)
    @applied_Departments ={}
    if params.include? "gre"
      @current_profile.gre = params[:gre]
      @current_profile.toefl = params[:toefl]
      @current_profile.capa = params[:capa]
      @current_profile.interested_major =params[:major]
      @current_profile.term = params[:term]
      @current_profile.year = params[:year]
      @current_profile.college_name = params[:college_name]
      @current_profile.save
    elsif params.include? "department"
      @university= University.find(params[:university_id])
      @department = Department.find(params[:department])
      application = {:student_id=>@@id, :university_id=> @university.id,:department_id=>@department.id,:status=>"pending"}
      @applications.create!(application)
    end
    @applications = Application.where(student_id: @@id)

    @applications.each do |app|
      current_uni= University.find(app.university_id)
      current_dep = Department.find(app.department_id)

      if @applied_Departments.include? current_uni.name.to_sym
        @applied_Departments[current_uni.name.to_sym].append(current_dep.name)
      else
        @applied_Departments[current_uni.name.to_sym] = [current_dep.name]
      end
    end
  end


  def intermediate_sign_up
    @student = Student
    @profile= Profile

    puts params[:user]
    missing=false
    if Student.where(:email => (params[:user][:email])).exists? || Faculty.where(:email => (params[:user][:email])).exists?
      puts "email"
      flash[:notice]= "Email already in use"
      missing=true
    end
    if params[:user][:first_name].blank?
      puts "first"
      flash[:notice]= "Empty first name"
      missing=true
      # redirect_to main_intermediate_login_path
    elsif params[:user][:last_name].blank?
      puts "last"
      flash[:notice]= "Empty last name"
      missing=true
      # redirect_to main_intermediate_login_path
    elsif params[:user][:email].blank?
      puts "email"
      flash[:notice]= "Empty email"
      missing=true
      # redirect_to main_intermediate_login_path

    elsif params[:user][:password].blank?
      puts "pwd"
      flash[:notice]= "Empty password"
      missing=true
      # redirect_to main_intermediate_login_path
    elsif params[:type].blank?
      puts "radio"
      flash[:notice]= "Empty radio"
      missing=true
      # redirect_to main_intermediate_login_path
    end

    puts params
    if params[:type].present? && !missing
      if params[:type]=="radio_button_faculty"
        faculty={:first_name => params[:user][:first_name], :last_name => params[:user][:last_name],
                 :email => params[:user][:email],:password_digest=>params[:user][:password] }
        Faculty.create!(faculty)

        # id=@profile.where(email:params[:user][:email])
        # Commented out as we have yet to decide if we're making
        flash[:notice]= "Faculty Account created successfully"
      else
        #  create a student account
        student={:first_name => params[:user][:first_name], :last_name => params[:user][:last_name],
              :email => params[:user][:email],:password_digest=>params[:user][:password] }

        Student.create!(student)
        id=@student.where(email:params[:user][:email]).take.id
        puts id,"create"
        student_profile={:student_id=>id,:gre=>nil, :toefl => nil,
                         :interested_major => nil, :term => nil,
                         :year =>nil }

        Profile.create!(student_profile)

        flash[:notice]= "Student Account created successfully"
      end

    end
    redirect_to root_path


  end

  def edit_profile
    @current_profile = Profile.where(student_id: @@id).take
    puts @@id,"asdsada"
    @profiles.all.each do |p|
      puts p.student_id
    end
  end
  def faculty_profile

  end
  def intermediate_login
    given_email= params[:user][:email]
    given_password = params[:user][:password]

    #@student = Student.where( email:given_email).take

    #@faculty = Faculty.where( email: given_email).take
    #puts 'line 134: ', @student
    #p 'line 135  ', @faculty
    #if (not @student.nil?) || (not @faculty.nil?)
    @student = Student.find_by(email:given_email,password_digest:given_password)
    @faculty = Faculty.find_by(email:given_email,password_digest:given_password)

    begin
      puts 'line 139'
      if not @student.nil? #student1 && student1.authenticate(given_password)
        #&.authenticate(given_password)
        puts 'line 141'
        @@user_type = :student
        @@id = @student.id
        #p @student
        redirect_to view_profile_path
      #elsif not @faculty.nil?
      elsif not @faculty.nil?
        #&.authenticate(given_password)
        puts 'line 148'
        @@id = @faculty.id
        @@user_type = :faulty
        redirect_to faculty_profile_path

      else
         flash[:notice]="Invalid user"
         redirect_to login_path
      end
    rescue BCrypt::Errors::InvalidHash
      flash[:error] = 'We recently adjusted the way our passwords are store. Please Reset your password '
    end
    #else
    # flash[:notice]="Invalid user 2"
    #  redirect_to login_path

  end
  def reset_password
    #redirect_to reset_password_path

  end
  def search_universities
    @universities= @@universities
    @all_universities = []
    University.all.each do |u|
      @all_universities.append(u.name.downcase)
    end
    puts @all_universities
  end
  def view_university
    @university = University.where(name:params[:name]).take
    @departments = Department.where(university_id: @university.id)
    @departments.all.each do |d|
      puts d.name
    end
  end
  def intermediate_search
    filter = params[:filter]
    entry = params[:search]

    puts filter, filter.nil?,filter.blank?
    if filter == "Location"
      @@location = true
    elsif filter.blank? or entry.blank?
      flash[:notice] = "Please fill out all fields"
      @@location = false
    elsif filter == "Country"
      url = 'https://public.opendatasoft.com/api/records/1.0/search/?dataset=shanghai-world-university-ranking&q=&rows=100&sort=world_rank&facet=world_rank&facet=national_rank&facet=year&facet=country&refine.country='+entry+'&refine.year=2018'
      response = data = JSON.parse(open(url).read)
      @@universities = response["records"]
      @@location = false
    elsif filter == "university name"
      url = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=shanghai-world-university-ranking&q=&rows=1&sort=world_rank&facet=university_name&facet=world_rank&facet=national_rank&facet=year&facet=country&refine.university_name="+entry+"&refine.year=2018"
      response = data = JSON.parse(open(url).read)
      @@universities = response["records"]
      @@location = false
    end


    redirect_to search_universities_path

  end
end
