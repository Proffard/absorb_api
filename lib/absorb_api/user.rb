module AbsorbApi
  class User < Base
    include Relations

    attr_accessor :id, :department_id, :first_name, :middle_name, :last_name,
                  :username, :password, :email_address, :cc_email_addresses,
                  :language_id, :gender, :address, :address2, :city,
                  :province_id, :country_id, :postal_code, :phone,
                  :employee_number, :location, :job_title, :reference_number,
                  :date_hired, :date_terminated, :notes, :custom_fields,
                  :role_ids, :active_status, :is_learner, :is_admin,
                  :is_instructor, :external_id, :supervisor_id, :decimal2,
                  :string1, :decimal1, :string2, :decimal3, :job_title

    has_many :courses
    has_many :enrollments, :course_enrollment
    has_many :certificates
    has_many :resources

    def update(attrs)
      attrs.keys.each { |k| attrs[k.to_s.camelize] = attrs.delete(k) }
      attrs['Username'] = username

      response = AbsorbApi::Api.new.connection.put("users/#{id}", attrs)
      raise ValidationError if response.status == 500
      raise RouteNotFound if response.status == 405

      self
    end

    # gets all associated courses given a collection of users
    # all calls are called in parallel
    # users are chunked in groups of 105 to keep typhoeus from bogging down
    def self.courses_from_collection(users)
      courses = []
      connection = AbsorbApi::Api.new.connection
      users.each_slice(105) do |user_slice|
        connection.in_parallel do
          user_slice.each do |user|
            courses << connection.get("users/#{user.id}/courses")
          end
        end
      end
      courses.map do |response|
        response.body.map { |body| Course.new(body) }
      end.flatten
    end
  end
end
