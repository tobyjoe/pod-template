module Pod

  class ConfigureOSX
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform

      keep_demo = configurator.ask_with_answers("Would you like to include a demo application with your library", ["Yes", "No"]).to_sym

      framework = configurator.ask_with_answers("Which testing frameworks will you use", ["Specta", "None"]).to_sym

      case framework
        when :specta
          configurator.add_pod_to_podfile "Specta"
          configurator.add_pod_to_podfile "Expecta"

          configurator.add_line_to_pch "#define EXP_SHORTHAND"
          configurator.add_line_to_pch "#import <Specta/Specta.h>"
          configurator.add_line_to_pch "#import <Expecta/Expecta.h>"

          configurator.set_test_framework("specta")

        when :none
          configurator.set_test_framework("xctest")
      end

      prefix = nil

      loop do
        prefix = configurator.ask("What is your class prefix")

        if prefix.include?(' ')
          puts 'Your class prefix cannot contain spaces.'.red
        else
          break
        end
      end

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/osx/Example/PROJECT.xcodeproj",
        :platform => :osx,
        :remove_demo_project => (keep_demo == :no),
        :prefix => prefix
      }).run

      `mv ./templates/osx/* ./`
    end
  end

end
