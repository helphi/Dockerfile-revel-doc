---
title: Interceptors
layout: manual
github:
  labels:
    - topic-controller
godoc: 
    - InterceptFunc
    - InterceptMethod
    - When
---

An **Interceptor** is a function that is invoked by the framework `BEFORE` or `AFTER` an action invocation.  It allows a form of
[Aspect Oriented Programming](http://en.wikipedia.org/wiki/Aspect-oriented_programming),
which is useful for some common concerns such as:

* Request logging
* Error handling
* Statistics logging
* Authentication handling

In Revel, an interceptor can take one of three forms:
    
* A [Function Interceptor](#function_interceptor) 
* A [Method Interceptor](#method_interceptor)
* A [Controller Auto Interceptor](#controller_auto_interceptor)
     using the `revel.BeforeAfterFilter` filter 

An Interceptor has an [intercept](#intercept_times) point in the request ([When](https://godoc.org/github.com/revel/revel#When)) 
and returns a [Result](#results) or `nil`.

<div class="alert alert-warning">NOTE: Interceptors are called in the order that they are added.</div>

<a name="function_interceptor"></a>

### Function Interceptor

* A function meeting the [InterceptorFunc](https://godoc.org/github.com/revel/revel#InterceptorFunc) interface.
* Does **not have access to the specific** `Controller` invoked.
* May be applied to any / all Controllers in an application (by adding lines of code).


```go
// simple example or user auth
func checkUser(c *revel.Controller) revel.Result {
    if user := MyCheckAuth(c); user == nil {
        c.Flash.Error("Please log in first")
        return c.Redirect(App.Index)
    }
    return nil
}
func doNothing(c *revel.Controller) revel.Result { return nil }

func init() {
    revel.InterceptFunc(checkUser, revel.BEFORE, &App{})
    revel.InterceptFunc(doNothing, revel.AFTER, &App{})
    revel.InterceptFunc(checkUser, revel.BEFORE, &AnotherController{})
}
```



<a name="method_interceptor"></a>

### Method Interceptor

* A [InterceptorMethod](https://godoc.org/github.com/revel/revel#InterceptorMethod) method accepting no arguments and returning a [`revel.Result`](results.html).
* May **only intercept calls to the bound** [Controller](controllers.html).
* May **modify the invoked controller** as desired.
* A method interceptor signature may have one of these two forms, or both:
  * `func (c AppController) example() revel.Result`
  * `func (c *AppController) example() revel.Result // pointer`


```go
// simple method example

func (c Hotels) checkUser() revel.Result {
    if user := connected(c); user == nil {
        c.Flash.Error("Please log in first")
        return c.Redirect(App.Index)
    }
    return nil
}
    
func init() {
    revel.InterceptMethod(Hotels.checkUser, revel.BEFORE)
    revel.InterceptMethod(Room.checkVacant, revel.BEFORE)
}
```

### Controller Auto Interceptor
Controllers that have methods named `Before`,`After`,`Finally`,`Panic`, will be called in the 
same manner as the interceptor does. The method signature is a little different then normal 
to allow for method Overriding and cascades. ie if **Application** has 
**GorpController** controller embedded inside it and both define the 
`Before` method then what happens is the `GorpController.Before` 
is invoked before the `Application.Before`. The method signature must match the 
following syntax  

```
func (c Application) Before() (r revel.Result, a Application) {
...
func (c *GorpController) Before() (result revel.Result, controller *GorpController) {
```
**Notice** along with the revel.Result we return the Controller type. 
This is so when the application starts up it can determine which method belongs to what 
field in the controller (currently Go does not tell you this information). 
These work identical to the revel.Interceptors without any configuration.

On the `Before` method the deepest embedded struct with the `Before` method is run first, 
then the next deepest and so on until the top level. `After`, `Finally`, `Panic` 
are run from the top down

#### Controller Auto Interceptor Implementation
Add the filter `revel.BeforeAfterFilter` to revel.Filters on app/init.go. 
Ensure your function names match `func (c Application) Before() (r revel.Result, a Application)` 

<a name="intercept_times"></a>

## Intercept Times

An interceptor can be registered to run at four points in the request lifecycle; defined in [When()](https://godoc.org/github.com/revel/revel#When):

1. **BEFORE**
    * After the request has been [routed](routing.html), the [session, flash](sessionflash.html), and [parameters](parameters.html) decoded, but before the action has been invoked.
2. **AFTER**
    * After the request has returned a [Result](results.html), but before that Result has been applied.  These interceptors are not invoked if the action panicked.
3. **PANIC**
    * After a [panic](http://golang.org/pkg/builtin/#panic) exits an action or is raised from applying the returned Result.
4. **FINALLY**
    * After an action has completed and the Result has been applied.


<a name="results"></a>

## Results

Interceptors typically return `nil`, in which case the request continues to
be processed without interruption.

The effect of returning a non-`nil` [revel.Result](results.html) depends on [When()](https://godoc.org/github.com/revel/revel#When) the interceptor
was invoked.

1. **BEFORE** 
    -  No further interceptors are invoked, and neither is the action.
2. **AFTER** 
    - All interceptors are still run.
3. **PANIC** 
    - All interceptors are still run.
4. **FINALLY** 
    - All interceptors are still run.

In all cases, any returned [Result](results.html) will take the place of any existing Result.

* However, in the `BEFORE` case, the returned Result is guaranteed to be final,
* While in the `AFTER` case it is possible that a further interceptor could emit its own Result.



