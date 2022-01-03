# ACR Cleanup Action

GitHub Action to cleanup Docker images hosted on Azure Container Registry

## Usage

Create a new GitHub Actions workflow and call this action. Example:

    name: image-cleanup

    on:
      workflow_dispatch:
      schedule:
      - cron:  '0 3 * * *'

    jobs:
      delete-tags:
        name: "Delete old tags"
        runs-on: ubuntu-latest
        steps:
          - uses: Cleanshelf/acr-cleanup-action@master
            with:
              repository: si-backoffice-app
              secret-store-credentials: ${{ secrets.INJECTED_SECRET_STORE_CREDENTIALS }}
