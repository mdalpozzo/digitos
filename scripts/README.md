# Scripts

These are helpers and utility scripts that generally deal with app development and dev ops infrastructure like CI/CD, build and deployment.

### codemagic_env.sh

This is script that should be run in codemagic pre-build phase. It creates an .env file that the app then uses to dynamically inject API keys and other env vars and secrets. It relies on the existence of vars in the build environment. In code magic there is an env var section where you can define these values in a secure way. This will need to be updated when you update the .env structure.
