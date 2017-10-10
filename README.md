# Welcome to Terraformist

Terraformist is an attempt to make a simple framework for managing your terraform configurations and achieving maximum reuse.


## Example structure

Take for example the scenario of a staging environment, in AWS eu-central-1 region, and it's the route53 zones we want to manage. This could represented with the following structure:

```
└─ stg-aws-euc1  <-- collection
    ├── bastion
    │   ├── main.tf
    │   └── ...
    ├── kubernetes  <-- component
    │   ├── main.tf
    │   └── ...
    ├── route53_zones
    │   ├── main.tf
    │   └── ...
    ├── vpc
    │   ├── main.tf
    │   └── ...
    └── _shared
        └── provider.tf
```

Using this structure, you could easily represent many more components in that environment and region without having to keep duplicating the provider settings, as just one example, since they could be inherited from the `_shared` folder for that `collection`. Other things you could do is restrict certain collections to specific accounts, or versions of terraform, or anything really.


### Special folders

There are several special constructs within this project. Namely all the folders who's names start with an `_` character are special in some way. They are `_scripts`, and `_modules` & `_shared` (which is special and can appear at different levels/locations).

 - [`_modules`](_modules): this is where our shared/reusable modules for Terraform live
 - [`_scripts`](_scripts): these are our helper scripts we use to run Terraform and related tasks
 - [`_shared`](_shared): shared shippets that are applied to all child configs (global, collections, or components)


### Logical grouping constructs

We have two grouping mechanisms in this project:

 1. collections
 1. components


#### Collections

This is a bit of a meta collection. In our default use case, we'll typically use this to group by provider & region/location, but it could be anything. For example you could have many different providers, like AWS, Google, Azure, etc. Each of them might be in some different regions, or some services you want to use might not even have a region, like a DNS service. In which case this meta collection concept is a better and more flexible approach, as the terminology shouldn't get in the way of you using this construct, which is esentially a group, nothing more.


#### Components

This is the thing you're wanting to manage, it could be a single resource type, it could be some bundle of things which makes an logical component in your stack/application. Focus on keeping clean separation of concerns, if I'm updating an ELB, ASG, and some DNS records for an application, I shouldn't be touching my VPC and subnets or IAM users.


## Running terraform

To improve usability we adopted this powerful but flexible structure to the project, which means that there is some setup and options that you must use to run Terraform. To make this as painless as possible, repeatable, and reliable, we provide Makefiles with some helper scripts.


### Normal usage

To use Terraform via the Makefile, the usual cycle consists of init, plan, apply. Which looks like:

```
make target=stg-aws-euc1/route53_zones init
make target=stg-aws-euc1/route53_zones plan
make target=stg-aws-euc1/route53_zones apply

git commit ...  # This step is necessary to commit updated *.tfstate files to the repo
```

The beauty of this setup is that the target is a file path, so you can use your shells tab completion to complete the path for you.


Also for convenience, there's a number of other helper tasks available:

```
make collection collection="<ENV-HERE>"
```

Which iterates through all the components in an collection and runs the `plan` task against them, this is a nice way of quickly seeing if all the components are in the correct state or not.


```
make target=<TARGET-HERE> run args="<ARGS-HERE>
```

This is a shortcut for running any arbitrary Terraform command against a particular component. This is actually what the `init`, `plan` and `apply` targets use under the hood to run their respective tasks. This is useful for instance for running `get` `state ...` and similar Terraform commands for a component.


### Debugging

Between the helper scripts we use via Make and Terraform there are a couple of constructs we can use to debug things.

The first is to see what the helper scripts are doing, you can export or prepend a DEBUG variable to your commands like so:

```
DEBUG=1 make target=stg-aws-euc1/route53_zones plan
```

This causes the helper scripts to run in `set -x` mode, so they'll print all operations and evaluations during their execution.


If the problem is in Terraform and not the helper scripts, there's another variable you can also export/prepend like so:

```
TF_LOG=info make target=stg-aws-euc1/route53_zones plan
```


And of course you can combine these two options, and debug everything at the same time.



### Advanced/manual usage

There are two more advanced routes you could take if something isn't working correctly and you really must:

 1. Manually invoke the helper scripts. It's ___VERY___ important to read the Makefile first and fully understand the options that are normally passed to the scripts, so that everything is set up correctly.
 1. Manually invoke Terraform directly. This entails first using the setup helper script to compile any shared snippets or variables, and then running Terraform directly with the correct options. Again to do this ___MUST___ have read and fully understood the Makefile and then pass the appropriate options to Terraform directly.
