test:
	@bundle exec rspec spec

mutate:
	@bundle exec mutant --include lib --require lsp --use rspec "Lsp::FileLanguageServer"
