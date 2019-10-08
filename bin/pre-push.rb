#!/usr/bin/env ruby

`swift test`
raise 'Test failed' unless $?.success?
