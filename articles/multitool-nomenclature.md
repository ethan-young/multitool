# multitool Nomenclature

`multitool` uses a set of argument naming conventions to help users.

Whereas multitool function names are meant to describe what they do, the
first argument of each function is meant to help users understand
***which*** multitool objects should be passed to a particular function.

I designed first argument names to follow the steps for setting up,
building, running, unpacking, and summarizing a multiverse-style
analysis. They are as follows:

1.  `.df` = the original data set
2.  `.pipeline` = a data analysis pipeline blueprint produced by calling
    a series of add\_\* functions
3.  `.grid` = a data analysis pipeline fully expanded into all possible
    combinations of decisions outlined by the `.pipeline` blueprint
4.  `.multi` = a set of results produced by running an analysis across
    all rows of a `.grid`
5.  `.unpacked` = a specific set of results that have been unnested for
    plotting or summarizing
6.  `.condensed` = a specific set of results that have been summarized

These conventions make more sense when visualized across a typical
`multitool` workflow:
