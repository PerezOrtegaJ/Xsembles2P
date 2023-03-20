# Xsembles2P
**Xsembles2P** is a tool to analyze two-photon calcium imaging videos to extract neuronal activity and identify xsembles (ensembles and offsembles). The MATLAB function to use it is `Xsembles_2P.m`.

The algorithm performs the following computations:

1. Read raw video(s).
2. Read external voltage recording file(s).
3. Perform registration (based on animal locomotion).
4. Find active neurons.
5. Get calcium signals.
6. Do spike inference.
7. Get population activity (binary raster).
8. Find ensembles (and offsembles).
9. Save results.
10. Plot results.

## How to run Xsembles2P
You will need a raw calcium imaging video (TIF or AVI file format). Then, select your file when you run the function without any extra input arguments (using the default properties). Here are three options to do it:

```matlab
Xsembles_2P()
```
or
```matlab
Xsembles_2P('')
```
or
```matlab
Xsembles_2P(filepath)
```

## How to run Xsembles2P specifying the sampling period and neuron radius
The common parameters to change are: the sampling period (in seconds) and the neuron radius (in pixels). Here is an example of how to specify the samplig period to 0.1 seconds and a neuron radius size of 4 pixels:
```matlab
Xsembles_2P('','SamplingPeriod',0.1,'NeuronRadius',4)
```

# Xsembles2P - Viewer
**Xsembles2P - Viewer** is not oly a GUI to run `Xsembles_2P.m` but also to plot the results generated. The MATLAB function to use it is `Xsembles_2P_Viewer.m`. Use the following code to run it:

```matlab
Xsembles_2P_Viewer
```

<img src="https://github.com/PerezOrtegaJ/Xsembles2P/blob/c6848f957569408555e8bc3b92a651cea46132ff/Images/Xsembles_2P_Viewer_Analyze.png" width=50% height=50%><img src="https://github.com/PerezOrtegaJ/Xsembles2P/blob/c6848f957569408555e8bc3b92a651cea46132ff/Images/Xsembles_2P_Viewer_Visualize.png" width=50% height=50%>
<img src="https://github.com/PerezOrtegaJ/Xsembles2P/blob/c6848f957569408555e8bc3b92a651cea46132ff/Images/Raster.png" width=100% height=100%>
