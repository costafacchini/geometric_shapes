# Coding Challenge

Develop a RESTful API in Ruby on Rails (API-only) for registering and managing squares and circles, following geometric positioning and spatial limitation rules. All distances and dimensions must be expressed in centimeters, allowing decimal values.

## Requirements

- [X] Ruby on Rails (API-only);
- [X] Docker Compose for container orchestration;
- [X] PostgreSQL (or MySQL) as database;
- [] RSpec for automated tests covering all success and error scenarios for each endpoint;
- [] Swagger/OpenAPI for endpoint documentation with request and response examples, models and status codes;
- [X] README with setup and execution instructions

## Business rules

- [] Central position of squares and circles (X and Y axes) in centimeters, supporting decimal values;
- [] Square dimensions (width and height) in centimeters, supporting decimal values;
- [] Circle diameter in centimeters, supporting decimal values;
- [] A square can contain N circles;
- [] A circle can never touch another circle within the same square;
- [] A circle must fit completely inside the square: every point of the circle must stay within the square's borders (can touch, but not exceed);
- [] A circle must always belong to an existing square;
- [] A square cannot touch another square: the borders of squares cannot intersect or touch;

## Endpoints

POST /frames
- [] Creates a new square, receiving the position, height and width. Can also receive circles to be created together;
- [] Returns 201 Created on success or 422 Unprocessable Entity on validation errors;

POST /frames/:frame/:id/circles
- [] Adds a circle to the specified square;
- [] Returns 201 Created on success or 422 Unprocessable Entity on validation errors;

PUT /circles/:id
- [] Updates the position of an existing circle;
- [] Returns 200 OK on success or 422 Unprocessable Entity on validation errors;

GET /circles?center_x=X&center_y=Y&radius=R&frame_id=ID
- [] Lists all circles completely within the specified radius (in centimeters) from a central point, optionally filtered by square;
- [] Returns 200 OK with the list of circles;

GET /fames/:id
- [] Returns details of a square, including:
  - [] x position
  - [] y position
  - [] total number of circles
  - [] position of the circle that is in the highest position
  - [] position of the circle that is in the lowest position
  - [] position of the circle that is in the leftmost position
  - [] position of the circle that is in the rightmost position
- [] Returns 200 OK with the square data and circle metrics;

DELETE /circles/:id
- [] Removes a circle;
- [] Returns 204 No Content on success or 404 Not Found on error;

DELETE /frames/:id
- [] Removes a square only if there are no associated circles;
- [] Returns 204 No Content on success or 422 Unprocessable Entity on error;

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

# run linter (backend)
$ bin/rubocop
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