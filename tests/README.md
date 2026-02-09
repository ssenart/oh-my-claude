# Tests

Unit tests for oh-my-claude scripts using [bats-core](https://github.com/bats-core/bats-core).

## Installation

### Install bats-core

**Ubuntu/Debian:**
```bash
sudo apt install bats
```

**macOS:**
```bash
brew install bats-core
```

**Manual installation:**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

## Running Tests

### Run all tests:
```bash
bats tests/*.bats
```

### Run specific test file:
```bash
bats tests/common.bats
bats tests/statusline.bats
```

### Run with verbose output:
```bash
bats -t tests/*.bats
```

### Run with TAP output:
```bash
bats --tap tests/*.bats
```

## Test Structure

```
tests/
├── README.md              # This file
├── common.bats            # Tests for common.sh
├── statusline.bats        # Tests for statusline.sh
├── fetch-code-usage.bats  # Tests for fetch-code-usage.sh
├── fetch-pro-usage.bats   # Tests for fetch-pro-usage.sh
└── update-usage.bats      # Tests for update-usage.sh
```

## Writing Tests

Each test file follows the bats format:

```bash
#!/usr/bin/env bats

setup() {
    # Run before each test
}

teardown() {
    # Run after each test
}

@test "description of test" {
    run command_to_test

    [ "$status" -eq 0 ]
    [ "$output" = "expected output" ]
}
```

## CI/CD Integration

Add to your CI pipeline:

**GitHub Actions:**
```yaml
- name: Install bats
  run: npm install -g bats

- name: Run tests
  run: bats tests/*.bats
```

**GitLab CI:**
```yaml
test:
  script:
    - apt-get install -y bats
    - bats tests/*.bats
```

## Coverage

Current test coverage:
- ✅ common.sh - Core functions tested
- ✅ statusline.sh - Main execution flow tested
- ⚠️ fetch-code-usage.sh - Requires ccusage mock
- ⚠️ fetch-pro-usage.sh - Requires credentials mock
- ⚠️ update-usage.sh - Requires fetch script mocks

## Contributing

When adding new features:
1. Write tests first (TDD)
2. Ensure all tests pass
3. Add integration tests for complex workflows
