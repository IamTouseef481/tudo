common_checks = [
  {Credo.Check.Consistency.ExceptionNames},
  {Credo.Check.Consistency.LineEndings},
  {Credo.Check.Consistency.SpaceAroundOperators},
  {Credo.Check.Consistency.SpaceInParentheses},
  {Credo.Check.Consistency.TabsOrSpaces},
  {Credo.Check.Design.AliasUsage, if_called_more_often_than: 2, if_nested_deeper_than: 1},
  {Credo.Check.Design.TagTODO},
  {Credo.Check.Design.TagFIXME},
  {Credo.Check.Readability.AliasOrder},
  {Credo.Check.Readability.FunctionNames},
  {Credo.Check.Readability.LargeNumbers},
  {Credo.Check.Readability.MaxLineLength, max_length: 200},
  {Credo.Check.Readability.ModuleAttributeNames},
  {Credo.Check.Readability.ModuleDoc, false},
  {Credo.Check.Readability.ModuleNames},
  {Credo.Check.Readability.ParenthesesInCondition},
  {Credo.Check.Readability.PredicateFunctionNames},
  {Credo.Check.Readability.StrictModuleLayout},
  {Credo.Check.Readability.TrailingBlankLine},
  {Credo.Check.Readability.TrailingWhiteSpace},
  {Credo.Check.Readability.VariableNames},
  {Credo.Check.Readability.WithSingleClause},
  {Credo.Check.Refactor.ABCSize, max_size: 42},
  {Credo.Check.Refactor.CondStatements},
  {Credo.Check.Refactor.FunctionArity},
  {Credo.Check.Refactor.MapInto, false},
  {Credo.Check.Refactor.MatchInCondition},
  {
    Credo.Check.Refactor.PipeChainStart,
    excluded_argument_types: ~w(atom binary fn keyword)a, excluded_functions: ~w(from)
  },
  {Credo.Check.Refactor.CyclomaticComplexity},
  {Credo.Check.Refactor.NegatedConditionsInUnless},
  {Credo.Check.Refactor.NegatedConditionsWithElse},
  {Credo.Check.Refactor.Nesting, max_nesting: 3},
  {Credo.Check.Refactor.WithClauses},
  {Credo.Check.Refactor.UnlessWithElse},
  {Credo.Check.Warning.IExPry},
  {Credo.Check.Warning.IoInspect},
  {Credo.Check.Warning.LazyLogging, false},
  {Credo.Check.Warning.OperationOnSameValues},
  {Credo.Check.Warning.BoolOperationOnSameValues},
  {Credo.Check.Warning.UnusedEnumOperation},
  {Credo.Check.Warning.UnusedKeywordOperation},
  {Credo.Check.Warning.UnusedListOperation},
  {Credo.Check.Warning.UnusedStringOperation},
  {Credo.Check.Warning.UnusedTupleOperation},
  {Credo.Check.Warning.OperationWithConstantResult},
  {CredoEnvvar.Check.Warning.EnvironmentVariablesAtCompileTime},
  {
    CredoNaming.Check.Warning.AvoidSpecificTermsInModuleNames,
    terms: [
      "Manager",
      "Fetcher",
      "Builder",
      "Persister"
    ]
  },
  {
    CredoNaming.Check.Consistency.ModuleFilename,
    excluded_paths: [
      "config",
      "mix.exs",
      "priv",
      "apps/core/priv",
      "apps/tudo_chat/priv"
      ],
    acronyms: [{"CoreGraphQL", "core_graphql"}, {"GraphQL", "graphql"}]
  }
]

%{
  configs: [
    %{
      name: "default",
      strict: true,
      parse_timeout: 5000,
      files: %{
        included: [
          "apps/core/lib/",
          "apps/tudo_chat/lib/",
          "apps/core/priv/",
          "apps/tudo_chat/priv/",
          "apps/core/config/",
          "apps/tudo_chat/config/",
          "apps/tudo_chat/rel/",
          "apps/core/rel/"
          ],
        excluded: ["lib/core/scripts/"]
      },
      checks:
        common_checks ++
          [
            {Credo.Check.Design.DuplicatedCode, excluded_macros: []}
          ]
    },
    %{
      name: "test",
      strict: true,
      files: %{
        included: ["apps/core/test/", "apps/tudo_chat/test/"],
        excluded: []
      },
      checks: common_checks
    }
  ]
}
