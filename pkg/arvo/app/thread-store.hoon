:: thread-store: data store that holds recursively branching threads
::
/-  *thread-store
|%
+$  move  [bone card]
::
+$  card
  $%  [%diff diff]
      [%quit ~]
  ==
::
+$  state
  $%  [%0 state-zero]
  ==
::
+$  state-zero
  $:  =fabric
  ==
::
+$  diff
  $%  [%thread-initial thread-initial]
      [%thread-update thread-update]
  ==
--
::
|_  [bol=bowl:gall state]
::
++  this  .
::
++  prep
  |=  old=(unit state)
  ^-  (quip move _this)
  [~ ?~(old this this(+<+ u.old))]
::
::  +queries: return data via scry or subscription
::
++  peek-x-all
  |=  pax=path
  ^-  (unit (unit [%noun (map path threads)]))
  [~ ~ %noun fabric]
::
++  peek-x-keys
  |=  pax=path
  ^-  (unit (unit [%noun (set path)]))
  [~ ~ %noun ~(key by fabric)]
::
++  peek-x-threads
  |=  pax=path
  ^-  (unit (unit [%noun threads]))
  ?~  pax
    ~
  =/  threads  (~(get by fabric) pax fabric)
  ?~  threads
    ~
  [~ ~ %noun u.threads]
::
++  peek-x-thread
  |=  pax=path
  ^-  (unit (unit [%noun thread]))
  ::  /:ship/:serial/:path
  =/  index  (path-to-index pax)
  =/  threads  (~(get by fabric) path.index)
  ?~  threads
    ~
  =/  thread  (~(get by u.threads) uid.index)
  ?~  thread
    ~
  [~ ~ %noun u.thread]
::
++  peek-x-package
  |=  pax=path
  ^-  (unit (unit [%noun package]))
  ::  /:ship/:serial/:ship/:serial/:path
  =/  thread-index  (path-to-index pax)
  =/  threads  (~(get by fabric) path.index)
  ?~  threads
    ~
  =/  thread  (~(get by u.threads) uid.index)
  ?~  thread
    ~
  =/  post-index  (path-to-index path.index)
  ::  TODO: keep going
  [~ ~ %noun *package]
::
::  TODO: write expanded scries
::
::++  peek-x-expanded-threads
::  |=  pax=path
::  ^-  (unit (unit [%noun expanded-threads]))
::  ::  /:uid/:path
::  ?~  pax
::    ~
::  [~ ~ %noun *expanded-threads]
::::
::++  peek-x-expanded-thread
::  |=  pax=path
::  ^-  (unit (unit [%noun expanded-thread]))
::  ::  /:uid/:path
::  ?~  pax
::    ~
::  [~ ~ %noun *expanded-thread]
::::
::++  peek-x-expanded-package
::  |=  pax=path
::  ^-  (unit (unit [%noun expanded-package]))
::  ::  /:uid/:uid/:path
::  ?~  pax
::    ~
::  [~ ~ %noun *expanded-package]
::
++  peer-keys
  |=  pax=path
  ^-  (quip move _this)
  ?>  (team:title our.bol src.bol)
  ::  we send the list of keys then send events when they change
  :_  this
  [ost.bol %diff %thread-update [%keys ~(key by fabric)]]~
::
++  peer-fabric
  |=  pax=path
  ^-  (quip move _this)
  ?>  (team:title our.bol src.bol)
  :_  this
  [ost.bol %diff %thread-initial [%fabric fabric]]~
::
++  peer-updates
  |=  pax=path
  ^-  (quip move _this)
  ?>  (team:title our.bol src.bol)
  ::  we now proxy all events to this path
  [~ this]
::
++  peer-threads
  |=  pax=path
  ^-  (quip move _this)
  ?>  (team:title our.bol src.bol)
  ?~  pax
    !!
  =/  threads  (~(get by fabric) pax fabric)
  :_  this
  [ost.bol %diff %thread-initial [%threads threads]]~
::
++  peer-thread
  |=  pax=path
  ^-  (quip move _this)
  ?>  (team:title our.bol src.bol)
  =/  index  (path-to-index pax)
  =/  threads  (~(got by fabric) path.index fabric)
  =/  thread  (~(got by threads) uid.index threads)
  :_  this
  [ost.bol %diff %thread-initial [%thread thread]]~
::
::  +actions: handle actions, update state, and send diffs
::
++  poke-thread-action
  |=  action=thread-action
  ^-  (quip move _this)
  ?>  (team:title our.bol src.bol)
  ?-  -.action
      %path           (handle-path +.action)
      %thread         (handle-thread +.action)
      %post           (handle-post +.action)
      %delete-path    (handle-delete-path +.action)
      %delete-thread  (handle-delete-thread +.action)
      %delete-post    (handle-delete-post +.action)
      %read           (handle-read +.action)
  ==
::
++  handle-path
  |=  =path
  ^-  (quip move _this)
  ?:  (~(has by fabric) path)
    [~ this]
  :-  (send-diff path *uid [%path path])
  this(fabric (~(put by fabric) path *threads))
::
++  handle-thread
  |=  [=path =uid =thread]
  ^-  (quip move _this)
  ?.  (~(has by fabric) path)
    [~ this]
  =/  threads  (~(got by fabric) path)
  ?:  (~(has by threads) uid)
    [~ this]
  =.  threads  (~(put by threads) uid thread)
  :-  (send-diff path uid [%thread path uid thread])
  this(fabric (~(put by fabric) path threads))
::
++  handle-post
  |=  [=path =post target=(unit target-post)]
  ^-  (quip move _this)
  ::  if uid does not exist, create it.
  ?.  (~(has by fabric) path)
    [~ this]
  ?~  target
    (create-post path post)
  (reply-post path post u.target)
::
++  create-post
  |=  [=path =post]
  ^-  (quip move _this)
  =/  threads  (~(got by fabric) path)
  =/  =package  *package
  =/  =thread   *thread
  =.  post.package  post
  =:  packages.thread  (snoc packages.thread package)
      length.config.thread  1
      indices.thread  (~(put by indices.thread) uid.post 0)
  ==
  =.  threads  (~(put by threads) uid.post thread)
  :_  this(fabric (~(put by fabric) path threads))
  (send-diff path uid.post [%post path post ~])
::
++  reply-post
  |=  [=path =post target=target-post]
  ^-  (quip move _this)
  =/  threads  (~(got by fabric) path)
  =/  thread=(unit thread)  (~(get by threads) thread.target)
  ?~  thread
    [~ this]
  =/  index=(unit @)  (~(get by indices.u.thread) post.target)
  ?~  index
    [~ this]
  ?:  =(u.index length.config.u.thread)
    (append-reply-post path post target u.thread threads)
  (create-reply-thread path post target u.thread threads)
::
++  append-reply-post
  |=  [=path =post target=target-post =thread =threads]
  ^-  (quip move _this)
  =/  =package  *package
  =:  post.package  post
      length.config.thread  +(length.config.thread)
  ::
      indices.thread
    (~(put by indices.thread) uid.post +(length.config.thread))
  ==
  =.  packages.thread  (snoc packages.thread package)
  =.  threads  (~(put by threads) thread.target thread)
  :_  this(fabric (~(put by fabric) path threads))
  (send-diff path thread.target [%post path post `target])
::
++  create-reply-thread
  |=  [=path =post target=target-post parent=thread =threads]
  ^-  (quip move _this)
  =/  new-thread  *thread
  =/  new-package  *package
  =/  parent-index  (~(got by indices.parent) post.target)
  =/  old-package  (snag parent-index packages.parent)
  =:  length.config.new-thread  1
      reply-to.new-thread  `target
      indices.new-thread  (~(put by indices.new-thread) uid.post 0)
      post.new-package  post
      reply-threads.old-package  (snoc reply-threads.old-package uid.post)
  ==
  =.  packages.new-thread  (snoc packages.new-thread new-package)
  =.  threads  (~(put by threads) uid.post new-thread)
  =.  packages.parent  (swerve parent-index [old-package]~ packages.parent)
  =.  threads  (~(put by threads) thread.target parent)
  :_  this(fabric (~(put by fabric) path threads))
  (send-diff path thread.target [%post path post `target])
::
++  handle-read
  |=  [=path =uid]
  ^-  (quip move _this)
  =/  threads=(unit threads)  (~(get by fabric) path)
  ?~  threads
    [~ this]
  =/  thread=(unit thread)  (~(get by u.threads) uid)
  ?~  thread
    [~ this]
  =.  read.config.u.thread  length.config.u.thread
  =.  u.threads  (~(put by u.threads) uid u.thread)
  :-  (send-diff path uid [%read path uid])
  this(fabric (~(put by fabric) path u.threads))
::
++  handle-delete-path
  |=  =path
  ^-  (quip move _this)
  ?.  (~(has by fabric) path)
    [~ this]
  :_  this(fabric (~(del by fabric) path))
  (send-diff path *uid [%delete-path path])
::
++  handle-delete-thread
  |=  [=path =uid]
  ^-  (quip move _this)
  =/  threads  (~(get by fabric) path)
  ?~  threads
    [~ this]
  ?.  (~(has by u.threads) uid)
    [~ this]
  =.  u.threads  (~(del by u.threads) uid)
  :-  (send-diff path uid [%delete-thread path uid])
  this(fabric (~(put by fabric) path u.threads))
::
++  handle-delete-post
  |=  [=path target=target-post]
  ^-  (quip move _this)
  =/  threads  (~(get by fabric) path)
  ?~  threads
    [~ this]
  =/  thread  (~(get by u.threads) thread.target)
  ?~  thread
    [~ this]
  =/  index  (~(get by indices.u.thread) post.target) 
  ?~  index
    [~ this]
  =.  indices.u.thread  (~(del by indices.u.thread) u.index)
  ?:  (gth u.index (lent packages.u.thread))
    ::  index is out of bounds, remove index
    ::
    =.  u.threads  (~(put by u.threads) thread.target u.thread)
    [~ this(fabric (~(put by fabric) path u.threads))]
  ::
  =:  packages.u.thread  (remove-package packages.u.thread u.index)
      indices.u.thread
    (update-package-indices packages.u.thread indices.u.thread)
  ::
      length.config.u.thread
    (dec length.config.u.thread)
  ::
      read.config.u.thread
    ?:  (gth read.config.u.thread length.config.u.thread)
      (dec read.config.u.thread)
    read.config.u.thread
  ::
      u.threads
    (~(put by u.threads) thread.target u.thread)
  ==
  :_  this(fabric (~(put by fabric) path u.threads))
  (send-diff path thread.target [%delete-post path target])
::
++  remove-package
  |=  [packages=(list package) index=@]
  ^-  (list package)
  ::  update list of packages to remove index
  =/  iter=@  0
  %+  skip  packages
  |=  =package
  =.  iter  +(iter)
  =(iter index)
::
++  update-package-indices
  |=  [packages=(list package) indices=(map uid @)]
  ^-  (map uid @)
  ::  update all indices in uid map
  =/  iter=@  0
  %-  ~(gas by *(map uid @))
  %+  turn  packages
  |=  [=post reply-threads=(list uid)]
  =.  iter  +(iter)
  [uid.post (dec iter)]
::
::  +utilities
::
++  new-uid
  |=  =ship
  ^-  uid
  [ship (shaf %thread-store-uid eny.bol)]
::
++  path-to-index
  |=  pax=path
  ^-  [uid path]
  ?>  ?=([* ^] pax)
  [[(slav %p i.pax) (slav %uv i.t.pax)] t.t.pax]
::
++  update-subscribers
  |=  [pax=path act=thread-action]
  ^-  (list move)
  %+  turn  (prey:pubsub:userlib pax bol)
  |=  [=bone *]
  [bone %diff %thread-update act]
::
++  swerve                                                ::  replace
  |*  [replace=@ new=(list) old=(list)]
  %-  zing
  :~  (scag replace old)
      new
      (slag +(replace) old)
  ==
::
++  send-diff
  |=  [pax=path =uid act=thread-action]
  ^-  (list move)
  ::  TOOD: write a real version of this
  %-  zing
  :~  (update-subscribers /all act)
      (update-subscribers /updates act)
      (update-subscribers [%thread pax] act)
      ?.  |(=(%post -.act) =(%delete-thread -.act))
        ~
      (update-subscribers /keys act)
  ==
--
