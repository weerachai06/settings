# PR Template Reference

When your PR is created, fill out the template using this structure:

## Header
```
[WEB] brief-description-of-changes
```

## Related JIRA
```
Related : JIRA [TICKET-NUMBER]
```

## Change Description
Explain in detail what this PR does and why.

## What kind of change?
Check the applicable box(es):
- [ ] New feature
- [ ] Bug fix
- [ ] Code improvement
- [ ] Service deployment
- [ ] Release
- [ ] FixDate

## Is this a breaking change?
- [ ] Yes
- [ ] No

## Test Evidence
Provide evidence of testing:
- Screenshots
- Test results
- Command output
- etc.

---

## Release Flow Templates

Used instead of the `[WEB]` template above when the source/target branch pair matches the release process:

| Source | Target | Flow |
|---|---|---|
| `releases/*` | `main` | Release |
| `sprint` | `dev` | Release |
| `releases/*` | `dev` | Merge Down |
| `dev` | `sprint` | Merge Down |

### Release (`releases/*` → `main`)

**Title:**
```
Release: [XXR X.X] Releases/vX.XXX.X
```

**Body:**
```
# 🚀 [Release XXR X.X](<link url to release>)
## Version X.XXX.X <!-- Copy version from package.json -->

## Change Description
- 

## What kind of change ?
- [x] Service deploymented.
- [ ] Merge down

## Is this a breaking change ?
- [ ] Yes
- [ ] No
```

### Merge Down (`releases/*` → `dev`, or `dev` → `sprint`)

**Title:**
```
[R X.X.X][Merge Down] <Source> => <Target>
```
e.g. `[R X.X.X][Merge Down] Dev => Sprint` or `[R X.X.X][Merge Down] Releases/vX.XXX.X => Dev`

**Body:**
```
# 🚀 [Release XXR X.X](<link url to release>)

## Change Description
- 

## What kind of change ?
- [ ] Service deploymented.
- [x] Merge down

## Is this a breaking change ?
- [ ] Yes
- [ ] No
```

---

**Contact**: pawanachai.seeruesang@kingpower.com
