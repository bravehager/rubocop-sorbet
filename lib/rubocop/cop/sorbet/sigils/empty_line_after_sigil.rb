# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Sorbet
      # Checks for a newline after Sorbet sigils.
      #
      # @example
      #   # good
      #   # typed: true
      #
      #   # Some documentation for Person
      #   class Person
      #     # Some code
      #   end
      #
      #   # bad
      #   # typed: true
      #   # Some documentation for Person
      #   class Person
      #     # Some code
      #   end
      class EmptyLineAfterTypeSigil < RuboCop::Cop::Cop
        include RangeHelp

        MSG = "Add an empty line after Sorbet sigils."

        def on_new_investigation
          return unless processed_source.ast &&
                        (last_type_sigil = last_type_sigil(processed_source))
          return if processed_source[last_type_sigil.loc.line].strip.empty?

          offending_range = offending_range(last_type_sigil)

          add_offense(nil, location: offending_range)
        end

        def autocorrect(_node)
          -> (corrector) do
            last_type_sigil = last_type_sigil(processed_source)
            corrector.insert_before(offending_range(last_type_sigil), "\n")
          end
        end

        private

        def offending_range(last_type_sigil)
          source_range(processed_source.buffer, last_type_sigil.loc.line + 1, 0)
        end

        # Find type sigil that does not have a newline or magic comment after it.
        #
        # @return [Parser::Source::Comment] if type sigil is found
        # @return [nil] otherwise
        def last_type_sigil(source)
          source
            .comments
            .take_while { |comment| comment.loc.line < source.ast.loc.line }
            .reverse
            .take_while { |comment| !MagicComment.parse(comment.text).any? }
            .find { |comment| comment.text.start_with?("# typed:") }
        end
      end
    end
  end
end
