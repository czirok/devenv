import type { Linter } from 'eslint'
import antfu from '@antfu/eslint-config'

const linters = antfu(
	{
		typescript: true,
		yaml: false,
		jsonc: true,
		markdown: true,
		formatters: {
			css: true,
			markdown: true,
			xml: true,
		},
		stylistic: {
			indent: 'tab',
			quotes: 'single',
		},
		ignores: [
			'**/dist',
			'**/node_modules',
			'**/*.js',
			'**/*.d.ts',
			'.vscode/.extensions',
			'.vscode/.user.data',
			'.vscode/.linux/.dotnet',
			'.pnpm-lock.yaml',
		],
		rules: {
			'unused-imports/no-unused-imports': 'warn',
		},
	},
)

const configs = await linters.toConfigs()

const antfuFormatterXml = configs.find(c => c.name === 'antfu/formatter/xml')
const antfuPrettierXmlOptions
	= Array.isArray(antfuFormatterXml?.rules?.['format/prettier'])
		&& antfuFormatterXml?.rules?.['format/prettier'].length > 1
		? antfuFormatterXml.rules?.['format/prettier'][1]
		: {}

if (antfuFormatterXml) {
	const msbuildConfig = {
		...antfuFormatterXml,
		name: 'antfu/formatter/msbuild',
		files: [
			'**/*.slnx',
			'**/*.props',
			'**/*.targets',
			'**/*.csproj',
			'**/*.csproj.user',
			'**/*.pubxml',
			'**/*.nuspec',
			'**/*.pkgproj',
		],
		rules: {
			...antfuFormatterXml.rules,
			'format/prettier': [
				'error',
				{
					...antfuPrettierXmlOptions,
					printWidth: 500,
					tabWidth: 2,
					useTabs: true,
					xmlWhitespaceSensitivity: 'ignore',
					endOfLine: 'lf',
				},
			],
		},
	} as Linter.Config
	linters.append(msbuildConfig)

	const xamlConfig = {
		...antfuFormatterXml,
		name: 'antfu/formatter/xaml',
		files: [
			'**/*.xaml',
		],
		rules: {
			...antfuFormatterXml.rules,
			'format/prettier': [
				'error',
				{
					...antfuPrettierXmlOptions,
					printWidth: 120,
					tabWidth: 4,
					useTabs: true,
					xmlWhitespaceSensitivity: 'ignore',
					endOfLine: 'crlf',
				},
			],
		},
	} as Linter.Config
	linters.append(xamlConfig)

	const plistConfig = {
		...antfuFormatterXml,
		name: 'antfu/formatter/plist',
		files: [
			'**/*.plist',
		],
		rules: {
			...antfuFormatterXml.rules,
			'format/prettier': [
				'error',
				{
					...antfuPrettierXmlOptions,
					printWidth: 120,
					tabWidth: 2,
					useTabs: true,
					xmlWhitespaceSensitivity: 'ignore',
					endOfLine: 'lf',
				},
			],
		},
	} as Linter.Config
	linters.append(plistConfig)

	const svgConfig = {
		...antfuFormatterXml,
		name: 'antfu/formatter/svg',
		files: [
			'**/*.svg',
		],
		rules: {
			...antfuFormatterXml.rules,
			'format/prettier': [
				'error',
				{
					...antfuPrettierXmlOptions,
					printWidth: 500,
					tabWidth: 2,
					useTabs: true,
					xmlWhitespaceSensitivity: 'ignore',
					endOfLine: 'lf',
				},
			],
		},
	} as Linter.Config
	linters.append(svgConfig)

	const markdownXmlConfig = {
		...antfuFormatterXml,
		name: 'antfu/formatter/markdownxml',
		files: [
			'**/*.md/*.xml',
		],
		rules: {
			...antfuFormatterXml.rules,
			'format/prettier': [
				'error',
				{
					...antfuPrettierXmlOptions,
					printWidth: 120,
					tabSize: 2,
					tabWidth: 2,
					useTabs: false,
					endOfLine: 'lf',
				},
			],
		},
	} as Linter.Config
	linters.append(markdownXmlConfig)
}

export default linters
