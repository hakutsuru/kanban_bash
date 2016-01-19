kanban-bash
==========

**tl;dr** A simple lock system via bash can ensure your continuous delivery system efficiently uses testing resources. I have used this in production on a single Jenkins server with Redis, but you could use it across multiple Jenkins servers using Amazon ElastiCache.

Orientation
-----------

See related project on rate limiting -- [kanban](https://github.com/hakutsuru/kanban).

I worked on a pipeline which used BrowserStack for front-end testing -- every commit to every branch got tested, and there were five testing workers. The setup was strange, with testing jobs created for every branch. This should be easy to imagine, five testing jobs could be running in parallel, but we were only allowed two front-end tests at once.

(This was nuts, so I replaced it with GitHub Pull Request Builder, but while untangling that mess, I had to make the pipeline more reliable. Clashes have been much less of a concern since, except that we have more than one build pipeline...)

When working with Jenkins, put bash scripts in files (and avoid [pitfalls](http://mywiki.wooledge.org/BashPitfalls)). If you have minimal code though, just put it in the Jenkins command, but then you are limited to posix syntax.

Redis was on the Jenkins server (for use with load testing). But it is such a simple store to install and configure, that I would add it to support resource locking.

Simulation
----------

It would have been easy to create Jenkins jobs to demo this, but then you would have to install Java and Jenkins, which would feel like a waste of time.

Clone the project, navigate to its vagrant folder, and provision the test environment.

```
$ cd ~/Repos/kanban_bash/vagrant/kanban_dev
$ vagrant up
```

When the environment is running, prepare five shells into the environment (e.g. five iTerm tabs/windows or five tmux panels, whatever).

```
$ cd ~/Repos/kanban_bash/vagrant/kanban_dev
$ vagrant ssh
```

Set up each shell to run the lock manager script, and launch each about the same time.

```
$ /bin/bash /opt/kanban_bash/tooling/pipeline-lock.sh 100
```

You should see results like those below -- the first two runs will execute tests right away, the next two will run tests after waiting, and the fifth terminal will time out.

### Terminal 1

```
$ /bin/bash /opt/kanban_bash/tooling/pipeline-lock.sh 100

###############################################
###############################################
########
########  007-test-frontend
########
###############################################
###############################################

########  request browserstack lock
>>>>>>>>  lock aquired
########  ] simulate-testing -- start :: 20151201-08:04:34
########  ] simulate-testing --   end :: 20151201-08:06:14
########  release browserstack lock
```



### Terminal 2

```
$ /bin/bash /opt/kanban_bash/tooling/pipeline-lock.sh 100

###############################################
###############################################
########
########  007-test-frontend
########
###############################################
###############################################

########  request browserstack lock
>>>>>>>>  lock aquired
########  ] simulate-testing -- start :: 20151201-08:04:35
########  ] simulate-testing --   end :: 20151201-08:06:15
########  release browserstack lock
```


### Terminal 3

```
$ /bin/bash /opt/kanban_bash/tooling/pipeline-lock.sh 100

###############################################
###############################################
########
########  007-test-frontend
########
###############################################
###############################################

########  request browserstack lock
>>>>>>>>  waiting....
>>>>>>>>  lock aquired
########  ] simulate-testing -- start :: 20151201-08:06:15
########  ] simulate-testing --   end :: 20151201-08:07:55
########  release browserstack lock
```



### Terminal 4

```
$ /bin/bash /opt/kanban_bash/tooling/pipeline-lock.sh 100

###############################################
###############################################
########
########  007-test-frontend
########
###############################################
###############################################

########  request browserstack lock
>>>>>>>>  waiting....
>>>>>>>>  lock aquired
########  ] simulate-testing -- start :: 20151201-08:06:16
########  ] simulate-testing --   end :: 20151201-08:07:56
########  release browserstack lock
```


### Terminal 5

```
$ /bin/bash /opt/kanban_bash/tooling/pipeline-lock.sh 100

###############################################
###############################################
########
########  007-test-frontend
########
###############################################
###############################################

########  request browserstack lock
>>>>>>>>  waiting........
>>>>>>>>  lock denied (timeout)
```

