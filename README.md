Dedicated homebrew tap for fwd.

Use with `brew`, i.e., `brew install decarabas/tap/fwd`

## Updating/Testing

1. Explicitly tap, if you haven't already. `brew tap decarabas/tap`
2. Edit the formula in `brew --repository decarabas/tap`
3. Test locally with:

```
$ env HOMEBREW_NO_INSTALL_FROM_API=1 brew install --verbose --debug decarabas/tap/fwd
$ brew test fwd
```

4. Push back to main
