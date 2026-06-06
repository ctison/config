#!/usr/bin/env -S nu

fnox get -P ctx7 CTX7_KEY | exec bun x @upstash/context7-mcp --api-key $in
