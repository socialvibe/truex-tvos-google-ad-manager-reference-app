# Overview

This project contains sample source code that demonstrates how to integrate the True[X]
ad renderer with the DFP IMA SDK in tvOS and iOS. This document will step through the
various pieces of code that make the integration work, so that the same basic ideas can
be replicated in a real production app.

# Assumptions

I assume here that you have either already integrated the IMA SDK with your app, or you are
working from a project that has been created following the instructions at the
[IMA SDK Quickstart page](https://developers.google.com/interactive-media-ads/docs/sdks/tvos/quickstart).
I also assume that you have already acquired the True[X] renderer code, either through
CocoaPods or direct download, and have added to your project appropriately.

# References

I have marked the source code with comments containing numbers in brackets: ("[3]", for
example), that correlate with the steps listed below. If you want to see how to fetch ad
parameters, search the `ViewController.m` file for `[4]` and you will find the related code.

# Steps

## [1] - Keep track of the current ad break

In order to properly control stream behavior around the True[X] engagement experience,
we need to know details about the current ad pod. However, we need to launch the renderer
after receiving information about an ad starting. Therefore, we need to keep track of the
ad break information separately.

In order to accomplish this, we create a private property on the `ViewController` called
`currentAdBreak` and we set it in the IMA delegate method `adBreakDidStart`.

## [2] - Look for True[X] companions for a given ad

In the IMA delegate method `adDidStart`, we inspect the `IMAAd`'s `companion` property. If
any companion has an `apiFramework` value matching `truex`, then we ignore all other
companions and begin the True[X] engagement experience.

## [3] - Prepare to enter the engagement

By default, the underlying ads, which IMA has stitched into the stream, will keep playing,
so the first we have to do is pause playback. There will also be a "placeholder" ad at the
first position of the ad break (this is the ad that contained the True[X] information that
allowed us to enter the engagement in the first place), so we need to seek over that ad
in any case. We will seek over the rest of the ad pod later, if the viewer earns that
experience.

## [4] - Fetch ad parameters

The `IMACompanion` object contains a URL which points to some configuration data needed
by the True[X] renderer. So, the first thing we have to do is go and fetch that. This
is accomplished by standard means, using `NSURLSession` and `NSJSONSerialization`.

## [5] - Initialize and start the renderer

Once we have the ad parameter dictionary, we can initialize our True[X] ad renderer and set
our `ViewController` as its delegate. Once the renderer is done initializing, it will call
its delegate method `onFetchAdComplete`, which we respond to by calling `start` on the ad
renderer.

## [6] - Respond to onAdFreePod

If the user fulfills the requirements to earn true[ATTENTION], the True[X] delegate method
`onAdFreePod` will be called, and we respond to it by seeking the underlying stream over the
current ad break. This accomplishes the "reward" portion of the engagement.

## [7] - Respond to terminal events

There are three ways the renderer can finish its job:

1. There were no ads available, which causes it to finish almost right away.
2. The ad had an error somehow.
3. The viewer has completed the engagement.

In all three of these cases, the renderer will have already removed itself from view, so all
we need to do is resume playback. If we had received the `onAdFreePod` delegate method earlier,
this resumption will be at the stream position immediately after the ad break; if not, it will
resume with the ad break itself.

## [8] - Respond to stream cancellation

Finally, it's possible that the viewer decided to exit the stream while the True[X] engagement
was ongoing. In this case, the renderer will dispatch the `onUserCancelStream` delegate method,
and we respond appropriately. In a real app, this would probably return to an episode list
screen or something along those lines. In this simple demo, it just exits the app.
