# Craiglist Room Finder

### Step 1: Install [Figaro](https://github.com/laserlemon/figaro)
- This will create `config/application.yml` file to keep your environment variables.

### Step 2: Register Google Application
- Need Gmail read/write permissions
- Will provide you with client id and secret along with a app name which you can set.
- Use these to set `APP_NAME`, `GOOGLE_CLIENT_ID`, and `GOOGLE_CLIENT_SECRET` in the `application.yml`.

## In Production Environment need to complete the following, if running locally skip to *Step 5*

### Step 3: Heroku API Key
- Autoscaler installed for the workers to keep costs down
- *If you are only running locally there is no need to set this.*
- If running in production on Heroku set the `HEROKU_API_KEY` environment variable in `application.yml`

### Step 4: Set Worker Rules
- The `WORKLESS_MAX_WORKERS`, `WORKLESS_MIN_WORKERS`, and `WORKLESS_WORKERS_RATIO` needs to be set as well in `application.yml`
- For information on what each of these does check the [workless documentation](https://github.com/lostboy/workless)

### Step 5: Create Account via Google OAuth
- Setup your email/subject after creating an account via google oauth.
- Once set go to [craigslist](http://sfbay.craigslist.org/) to filter what you are looking for.
- Copy this url and place in the Settings URL field.

### Step 6: Rake
- When in production setup Heroku Scheduler
- Or if local just run `rake scrape` to find new rooms then `rake email` to send emails out whenever you want!
