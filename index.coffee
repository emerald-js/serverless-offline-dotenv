import fs from 'fs'

export default class ServerlessOfflineDotEnv

	constructor: (@serverless, options) ->
		@path     = options['dotenv-path'] || "${process.env.PWD}/.env"
		@encoding = options['dotenv-encoding'] || 'utf-8'

		@hooks = {
			'before:offline:start:init': @run.bind(this)
		}

	run: ->
		return new Promise (resolve) =>
			oldenv = @serverless.service.provider.environment
			newenv = Object.assign(@dotenv(), oldenv)

			@serverless.service.provider.environment = newenv

			return resolve()

	dotenv: ->
		if @_dotenv
			return @_dotenv

		@_dotenv = {}

		if fs.existsSync(@path)
			@serverless.cli.log("Reading dotenv variables from ${this.path} (encoding: ${this.encoding})")

			fs.readFileSync(@path, { encoding: @encoding }).split('\n').forEach (line) =>
				matched = line.trim().match(/^([\w.-]+)\s*=\s*(.*)$/)

				if !matched
					return

				[, key, value] = matched;

				# Ignore comment lines
				if '#' == key[0]
					return

				# Remove quotes and whitespace
				@_dotenv[key] = value.replace(/(^['"]|['"]$)/g, '').trim()

		return @_dotenv
