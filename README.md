# Coding Challenge

Develop a RESTful API in Ruby on Rails (API-only) for registering and managing frames and circles, following geometric positioning and spatial limitation rules. All distances and dimensions must be expressed in centimeters, allowing decimal values.

## Requirements

- [X] Ruby on Rails (API-only);
- [X] Docker Compose for container orchestration;
- [X] PostgreSQL (or MySQL) as database;
- [] RSpec for automated tests covering all success and error scenarios for each endpoint;
- [] Swagger/OpenAPI for endpoint documentation with request and response examples, models and status codes;
- [X] README with setup and execution instructions

## Business rules

- [X] Central position of frames and circles (X and Y axes) in centimeters, supporting decimal values;
- [X] Frame dimensions (width and height) in centimeters, supporting decimal values;
- [X] Circle diameter in centimeters, supporting decimal values;
- [X] A frame can contain N circles;
- [X] A circle can never touch another circle within the same frame;
- [X] A circle must fit completely inside the frame: every point of the circle must stay within the frame's borders (can touch, but not exceed);
- [X] A circle must always belong to an existing frame;
- [X] A frame cannot touch another frame: the borders of frames cannot intersect or touch;

## Endpoints

POST /frames
- [X] Creates a new frame, receiving the position, height and width;
- [X] Can also receive circles to be created together;
- [X] Returns 201 Created on success or 422 Unprocessable Entity on validation errors;

POST /frames/:frame/:id/circles
- [X] Adds a circle to the specified frame;
- [X] Returns 201 Created on success or 422 Unprocessable Entity on validation errors;

PUT /circles/:id
- [] Updates the position of an existing circle;
- [] Returns 200 OK on success or 422 Unprocessable Entity on validation errors;

GET /circles?center_x=X&center_y=Y&radius=R&frame_id=ID
- [] Lists all circles completely within the specified radius (in centimeters) from a central point, optionally filtered by frame;
- [] Returns 200 OK with the list of circles;

GET /fames/:id
- [X] Returns details of a frame, including:
  - [X] x position
  - [X] y position
  - [X] total number of circles
  - [X] position of the circle that is in the highest position
  - [X] position of the circle that is in the lowest position
  - [X] position of the circle that is in the leftmost position
  - [X] position of the circle that is in the rightmost position
- [X] Returns 200 OK with the frame data and circle metrics;

DELETE /circles/:id
- [] Removes a circle;
- [] Returns 204 No Content on success or 404 Not Found on error;

DELETE /frames/:id
- [X] Removes a frame only if there are no associated circles;
- [X] Returns 204 No Content on success or 422 Unprocessable Entity on error;

## Setup Ruby (only if you have not installed)

This project uses [asdf](https://asdf-vm.com/guide/getting-started.html). \
Follow the installation [instructions](https://asdf-vm.com/guide/getting-started.html#_3-install-asdf)

After installation you need to follow these steps:

```bash
# Add ruby plugin on asdf
$ asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git

# Install ruby plugin
$ asdf install ruby 3.3.1
```

## Setup Project (without docker)

```bash
# install bundler
$ gem install bundler

# setup project
$ bin/setup
```

## Available Tasks

```bash
# run the project in development mode
$ bin/dev

# run all tests
$ bin/rspec

# run linter (backend)
$ bin/rubocop

# generate Swagger documentation
$ bundle exec rails rswag:specs:swaggerize
```

## Setup Project (with docker)

```bash
# build containers
docker compose build

# run the web container to initialize database
docker compose run web rails db:create db:setup

# run the web container to initialize database
docker compose up
```

## API Documentation

The API documentation is available at `/api-docs` when the server is running.
