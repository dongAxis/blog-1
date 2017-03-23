<!--
{
  "title": "Newton's Method",
  "date": "2016-07-01T22:08:25.000Z",
  "category": "",
  "tags": [
    "algorithm"
  ],
  "draft": false
}
-->

In a Go language tutorial (https://tour.golang.org), there's [one exercise](https://tour.golang.org/flowcontrol/8) to implement (approximated) square root function. 
I know this is a classic programming exercise applying Newton's method to calculating square. But sadly, I couldn't remember how this equation came up:

$$
x_{n+1} = x_n - \frac{x_n^2 - a}{2x_n}
$$

This post is for jogging my old memory about a bit of theory behind it.
I could go deeper about this subject. But for now, I only consider the simple case at least applicable to calculating square root.

----

# Rough Sketch

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-02-16.05.44-1024x768.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-02-16.05.44-1024x768.jpg" alt="2016-07-02 16.05.44" width="584" height="438" class="alignnone size-large wp-image-1107" /></a>

# The Case of Square Root

I follow notations from above sketch.

Problem is defined as follows:

- Given $a \le 0$, we want to calculate $r$ s.t. $a = r^2$ and $r >= 0$. 

The function $f$ should be defined by $f(x) = x^2 - a$ since 

$$
0 = f(x) \quad \Rightarrow \quad 0 = x^2 - a \quad \Rightarrow \quad a = x^2.
$$

We know $f'(x) = 2x$, so it's straightforward that we have this equation:

$$
x_{n+1} = x_n - \frac{x_n^2 - a}{2x_n}
$$

For the initial value $x_0$, you can start whatever positive number.


# Reference

- https://en.wikipedia.org/wiki/Newton%27s_method