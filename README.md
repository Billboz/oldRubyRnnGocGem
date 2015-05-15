![Alt text](http://giocoapp.github.io/goc/assets/images/logo.png "A gamification gem for Ruby on Rails applications")

# Goc (current version - 1.1.1)
A **gamification** gem to Ruby on Rails applications that use Active Record.

[![Dependency
Status](https://gemnasium.com/joaomdmoura/goc.png)](https://gemnasium.com/joaomdmoura/goc)
[![Coverage Status](https://coveralls.io/repos/joaomdmoura/goc/badge.png?branch=master)](https://coveralls.io/r/joaomdmoura/goc)
[![Code
Climate](https://codeclimate.com/github/joaomdmoura/goc.png)](https://codeclimate.com/github/joaomdmoura/goc)

## Description

**Goc** is an easy-to-implement gamification gem based on plug and play concepts.
With **Goc** you are able to implement gamification logic such as badges, levels and ratings / currencies.
Whether you have an existing database or starting from scratch, **Goc** will smoothly integrate everything and provide
all methods that you might need.

## ScreenCast

**Warning:** _it have some deprecated details._

A **Goc** overview screencast is available at [Youtube](http://www.youtube.com/watch?v=Pt2sAA8JuEg).

## Installation

**Goc** is available through [Rubygems](http://rubygems.org/gems/goc) and can be installed by:

adding it in Gemfile:

```ruby
gem :goc, github: "billboz/goc"
```

and running the bundler:

    $ bundle install

## Setup

**To setup Goc with your application:**

    rails g goc:setup

Next, you will be prompted to provide your **Resource Model**. This is generally the **User** model.

### Parameters:

**Goc** has two optional setup parameters, `--ratings` and `--domains`. These can be used together, or separately:

    rails g goc:setup --ratings --domains

`--ratings` argument will setup **Goc** with a ratings system;

`--domains` will setup an environment with multiple domains of badges.

If `--domains` is used with `--ratings` then `domains` will be able to represent domains of ratings as well.

You can read more about how the badge, level and ratings implementations work at the [Documentation](http://joaomdmoura.github.com/goc/).

## Usage

### Badge

After you've setup **Goc** in your application, you'll be able to add and remove **Badges** using the following commands:

**Note:** The DEFAULT (boolean) option is responsible for adding a specific badge to all **current** resource registrations.

#### Creating Badges

To add Badges you will use rake tasks.
Note: The arguments will change depending on which setup options you chose.

Examples:

For setups with `--ratings`:

    rake goc:add_badge[BADGE_NAME,RATINGS_NUMBER,DEFAULT]

For setups with `--domains`:

    rake goc:add_badge[BADGE_NAME,DOMAIN_NAME,DEFAULT]

For setups with `--ratings` and `--domains`:

    rake goc:add_badge[BADGE_NAME,RATINGS_NUMBER,DOMAIN_NAME,DEFAULT]

For setups without `--ratings` or `--domains`:

    rake goc:add_badge[BADGE_NAME,DEFAULT]

#### Destroying Badges

Example:

With `--domains` option:

    rake goc:remove_badge[BADGE_NAME,DOMAIN_NAME]

Without `--domains` option:

    rake goc:remove_badge[BADGE_NAME]

#### Destroying Domains

Example:

    rake goc:remove_domain[DOMAIN_NAME]

**Note:** Before destroying a domain, you must destroy all badges that relate to it.

## Methods

#### Let's assume that you have setup Goc defining your **User** model as the **Resource**

After adding the badges as you wish, you will have to start to use it inside your application,
and to do this, **Goc** will provide and attach some methods that will allow you to easily apply
any logic that you might have, without being concerned about small details.

### Resource Methods

Resource is the focus of your gamification logic and it should be defined in your setup process.

#### Change Ratings

Updating, adding or subtracting some amount of ratings of a resource. It will also remove or add the badges that was affected by the ponctuation change. **It will return a hash with the info related of the badges added or removed.** This method only is usefull when you setup the **Goc** with the ratings system.

**Note:** `domain_id` should be used only when you already used it as a setup argument.

```ruby
user = User.find(1)
user.change_ratings({ ratings: ratings, domain: domain_id }) # Adds or Subtracts some amount of ratings of a domain
```

If you have setup **Goc** without `--domains` then you should only pass the ratings argument instead of a hash:

```ruby
user = User.find(1)
user.change_ratings(ratings) # Adds or Subtracts some amount of ratings
```

#### Next Badge?

Return the next badge information, including percent and ratings info.

**Note:** `domain_id` should be used only when you already used it as a setup argument.

```ruby
user = User.find(1)
user.next_badge?(domain_id) # Returns the information related to the next badge the user should earn
```

#### Get Badges

In order to get the badges or levels of you resource, all you have to do is:

```ruby
user = User.find(1)
user.badges # Returns all user badges
```

### Badges Methods

#### Add

Add a Badge to a specific resource, **it will return the badge added, or if you are using ratings system it will return a hash with all badges that had been added**:

```ruby
badge = Badge.find(1)
badge.add(resource_id) # Adds a badge to a user
```

#### Remove

Remove a Badge of a specific resource, **it will return the badge removed, or if you are using ratings system it will return a hash with all badges that had been removed**:

```ruby
badge = Badge.find(1)
badge.remove(resource_id) # Removes a badge from a user
```

### Ranking Methods

#### Generate

**Goc** provides a method to list all Resources in a ranking inside of an array, the result format will change according the setup arguments you used (`--ratings` or/and `--domains`):

```ruby
Goc::Ranking.generate # Returns a object with the ranking of users
```

## Example

All basic usage flow to add **Goc** in an application:

#### Let's assume that you have setup Goc defining your _User_ model as the _Resource_:

```
$ rails g goc:setup --ratings --domains;
...
What is your resource model? (eg. user)
> user
```

Adding badges to the system using rake tasks, your badges have a pontuation and a domain in this case cause I setup **Goc** using `--ratings` and `--domains` arguments.

    # Adding badges of a teacher domain
    $ rake goc:add_badge[noob,0,teacher,true]
    $ rake goc:add_badge[medium,100,teacher]
    $ rake goc:add_badge[hard,200,teacher]
    $ rake goc:add_badge[pro,500,teacher]

    # Adding badges of a commenter domain
    $ rake goc:add_badge[mude,0,commenter,true]
    $ rake goc:add_badge[speaker,100,commenter]

Now **Goc** is already installed and synced with the applciation and six badges are created.

The both defaults badge (noob) already was added to all users that we already have in our database.

Inside your application if you want to give 100 ratings to some user, inside your function you have to use the following method:

```ruby
domain =  Domain.where(:name => "teacher")
user = User.find(1)

user.change_points({ ratings: 100, domain: domain.id })
```

Or if you wanna add or remove some badge **(consequently Goc will add or remove the necessary ratings)**:

```ruby
badge = Badge.where(:name => speaker)
user  = User.find(1)

badge.add(user.id)
badge.remove(user.id)
```

Get the information related to the next badge that the user want to earn:

```ruby
domain =  Domain.where(:name => "teacher")
user = User.find(1)

user.next_badge?(domain.id)
```

In order to get a ranking of all resources, all you need is call:

```ruby
Goc::Ranking.generate
```

## Deploy

Once that you decide that you are ready to deploy / update your application, if you added or removed any **domain** or
**badge**, you need to run the ```sync_database``` rake task, that will do the job of recreate your actions in production,
or any environments.

```
$ rake goc:sync_database
```

## License

**Goc** is released under the [MIT license](www.opensource.org/licenses/MIT).

## This is it!

Well, this is **Goc** I really hope you enjoy and use it a lot, I'm still working on it so dont be shy, let me know
if something get wrong opening a issue, then I can fix it and we help each other ;)
