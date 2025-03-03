# predictInterval-vs-bootMer

Debugging major discordance in uncertainty estimates using predictInterval()

**Update (2025-03-03)**:
- `predictInterval()` defaults to `include.resid.var = TRUE`, which means it produces prediction intervals, and not confidence intervals. The PIs for GLMMs [involve some strange combinations of deviation](https://github.com/jknowles/merTools/issues/131), and is therefore best avoided for the moment. In any case, we are interested in CIs too, not PIs. 
- It seems that the discrepancy between the widths of intervals reduces drastically when using `include.resid.var = FALSE`, and the two methods now seem rather comparable. 
- In this case, the following questions pop up:
    - Did the default behaviour of `predictInterval()` regarding `include.resid.var` change between our original 2023 analysis and the recent one?
    - This would seem to not be the case, as the commit history shows no such change recently. This would mean we have been calculating PIs during both the analyses, so why did PIs start behaving weirdly all of a sudden?
    - **Does switching to CIs solve our current problem of getting useful uncertainty estimates from the SoIB models?**