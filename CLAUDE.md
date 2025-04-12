# WebAuthor Gem - Quick Reference

## Build/Test/Lint Commands

### Running Tests

- Run all tests: `bundle exec rake test`
- Run single test file: `bundle exec ruby -Ilib:test path/to/test_file.rb`

### Linting & Security

- RuboCop: `bundle exec rubocop`
- RuboCop specific file: `bundle exec rubocop path/to/file.rb`
- RuboCop auto-fix: `bundle exec rubocop -A`

## General Approach

- Whenever you implement a request, I want you to split it in smaller meaningful steps. This will help you to better understand the problem and to write more maintainable code. Additionally, it will make your code easier to test and debug.
- Each change should be small and focused on solving a specific problem. This will make it easier to track down bugs and to make changes in the future.
- Each change should be able to be committed independently and thoroughly tested.

## Code Style Guidelines

### Ruby Style

- Frozen string literals required: `# frozen_string_literal: true`
- Single quotes for strings (unless interpolation needed)
- Line length: 120 characters maximum
- Indentation: 2 spaces
- Use snake_case for variables and methods, CamelCase for classes/modules
- Avoid 'is\_' prefix for predicate methods
- Memoized instance variables require leading underscore
- Prefer map over collect, inject over reduce
- Use good names OOP objects and for method names
- Use Data class for data immutable value objects when needed
- Do not comment code. Make it easy to be understood via naming and code organisation

### Error Handling

- Employ service objects pattern for connecting to external services. Else prefer OOP style with good namespaced classes
  living in app/models/<NAMESPACE>
- Failure cases should be explicit

### Testing

- Minitest is the testing framework. Use the spec way to write tests (test 'name' do/end).
- WebMock/VCR for HTTP request stubbing
- Mocha for mocking/stubbing
- Use fixtures only for data that might be used in the same way in multiple tests accors different namespaces/contexts.
- When I ask you to write tests, the name of the test should be imperative. It should describe what is tested and the expected outcome.
  Example:
  - DO NOT write "should be valid with valid attributes" for a booking test
  - Write instead, "booking is valid when using valid attributes."
  - Do not post comments about the structure of the test code. You should organise test code in Arrange, Act, Assert sections but the structure should be visible without any added comments.
- Whenever a new file is created, you should create a corresponding test file using Minitest
