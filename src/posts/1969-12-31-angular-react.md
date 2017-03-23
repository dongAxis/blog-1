<!--
{
  "title": "angular, react",
  "date": "1969-12-31T15:00:00.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

we need to think about why there's a gap between my feeling of react and one of other developer.

- I've never seriously think about the performance
- I've never made seriously component-based dynamic web app
- the way/depth of agile development styles
  - how seriously confirm before making something
- seriousness/familiarity of writing/rewriting html/js code
- I've never seriously done/required testing (seriousness of correctness of the app)

#### Things to consider
 - html, declarative goodness (still most of the case, web app is declarative)
 - agility
     - easy to transition from mockup to
     - easy-to-write (from mockup to production code), easy-to-modify
     - easy-to-extend
        - the situation where you want to same feature/function with different feelings (I would take angular)
            - angular: import global/utility service to the controller
            - react: pass the same handler props down to the component
            - react-redux: import action and connect to the component (with additional care of states architecture)
     - easy-to-read/understand
         - (number of files, dir-structure, content in one file)
         - still html (declarative way) is easy to read/understand
     - easy-to-maintenance
         - component based approach is not familar to everyone (meaning learning-cost), but once you get familiar, everything in js is easy to maintenance
 - framework vs. library
 - how do you care the performance (including server-side rendering)
 - how do you want to support native mobile as well
 - the types of "web application" you develop
   - how component will be reused
 - data flow is "clear and simple" is very subjective description. need justification.


__Angular__

_pros_

- html + js way (but js is so powerful)
- wiring up every state in html from js runtime (two-way binding)

_cons_

__React__

_pros_

- everything in js
- everything organized within js
- mobile app development (react native)
- data flow is simple/clear could mean "restrictive" to someone who uses javascript in ordinary way

_cons_


#### questions

which is better in what kinds of situation?

- angular: global service with two-way data binding directives
- react: props/state based one-way data passing

#### References

- http://jlongster.com/Removing-User-Interface-Complexity,-or-Why-React-is-Awesome

> The problem is that building apps is building components, so you inevitably are forced back into the manual DOM management to create your app-specific components
(note: depends on type of web apps)
> It makes it clear what state the component owns. (note: angular's directive is same)

- http://facebook.github.io/react/tips/communicate-between-components.html

> For communication between two components that don't have a parent-child relationship, you can set up your own global event system. Subscribe to events in componentDidMount(), unsubscribe in componentWillUnmount(), and call setState() when you receive an event. Flux pattern is one of the possible ways to arrange this. (note: this is ridiculous, I'll choose framework instead of library)

- http://facebook.github.io/react/tips/expose-component-functions.html