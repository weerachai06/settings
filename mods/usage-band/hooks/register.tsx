import { atom, read, update } from 'claude-code'
import type { Register, SessionContextUsage, SessionCost, SessionRateLimit } from 'claude-code'

import type { Usage } from '../types'

const usageAtom = atom({ plugin: 'usage-band', key: 'usage' } as const, null)

const LABELS: Record<string, string> = { five_hour: '5h', seven_day: '7d', spend_limit: 'spend' }
const BAR_WIDTH = 10

const compact = (n: number) =>
  n >= 1_000_000 ? `${(n / 1_000_000).toFixed(1)}M` : `${Math.round(n / 1000)}k`

const bar = (percent: number) => {
  const filled = Math.round((Math.min(percent, 100) / 100) * BAR_WIDTH)
  return '█'.repeat(filled) + '░'.repeat(BAR_WIDTH - filled)
}

const toUsage = (s: {
  context: SessionContextUsage
  rateLimits: SessionRateLimit[]
  cost?: SessionCost
}): Usage => ({
  tokens: s.context.tokens,
  window: s.context.window,
  percent: s.context.percent,
  rateLimits: s.rateLimits.map(r => ({ kind: r.kind, percentUsed: r.percentUsed })),
  usd: s.cost?.usd,
})

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const usage = toUsage(await $.session.usage())
    await update($, usageAtom, () => usage)

    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    await update($, usageAtom, () => toUsage(e))

    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const usage = await read($, usageAtom)

    if (e.props.hasSurvey || usage === null) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const percent = usage.percent ?? 0

    return (
      <Box>
        <Text dimColor>
          Context {bar(percent)} {percent}%
          {usage.tokens === undefined ? '' : ` (${compact(usage.tokens)}/${compact(usage.window)})`}
          {usage.rateLimits.map(r => ` · ${LABELS[r.kind] ?? r.kind} ${r.percentUsed}%`).join('')}
          {usage.usd === undefined ? '' : ` · ~$${usage.usd.toFixed(2)} est.`}
        </Text>
      </Box>
    )
  })
}
