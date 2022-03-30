# frozen_string_literal: true

require "spec_helper"

RSpec.describe(RuboCop::Cop::Sorbet::EmptyLineAfterTypeSigil, :config) do
  subject(:cop) { described_class.new(config) }

  it "adds offense when there is not an empty line after sigil" do
    expect_offense(<<~RUBY)
      # typed: false
      class MyClass
      ^ Add an empty line after Sorbet sigils.
      end
    RUBY

    expect_correction(<<~RUBY)
      # typed: false

      class MyClass
      end
    RUBY
  end

  it "does not add offense for magic comment after sigil" do
    expect_no_offenses(<<~RUBY)
      # typed: false
      # frozen_string_literal: true
      class MyClass
      end
    RUBY
  end

  it "adds offense for magic comment before sigil" do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # typed: false
      class MyClass
      ^ Add an empty line after Sorbet sigils.
      end
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
      # typed: false

      class MyClass
      end
    RUBY
  end

  it "does not add offense for empty line after sigil" do
    expect_no_offenses(<<~RUBY)
      # typed: false

      class MyClass
      end
    RUBY
  end

  it "does not add offense for empty file" do
    expect_no_offenses("")
  end

  it "adds one offense for multiple sigils" do
    expect_offense(<<~RUBY)
      # typed: false
      # typed: true
      class MyClass
      ^ Add an empty line after Sorbet sigils.
      end
    RUBY

    expect_correction(<<~RUBY)
      # typed: false
      # typed: true

      class MyClass
      end
    RUBY
  end

  it "does not add offense for file without sigil" do
    expect_no_offenses(<<~RUBY)
      class MyClass
      end
    RUBY
  end

  it "adds offense for non-magic comment after type sigil" do
    expect_offense(<<~RUBY)
      # typed: false
      # Some comment
      ^ Add an empty line after Sorbet sigils.
      class MyClass
      end
    RUBY

    expect_correction(<<~RUBY)
      # typed: false

      # Some comment
      class MyClass
      end
    RUBY
  end

  it "does not add offense for file with only type sigil" do
    expect_no_offenses(<<~RUBY)
      # typed: true
    RUBY
  end
end
