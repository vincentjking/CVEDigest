BeforeAll{
    . $PSScriptRoot\..\Config\SearchTerms.ps1
}

Describe CVEDigest{
    Context 'Check search terms'{
        It 'search terms contains 1 or more terms' {
            $searchTerms.count | Should -BeGreaterThan 0 
        }

        It 'search terms contains 10 or more terms' {
            $searchTerms.count | Should -BeGreaterThan 10 
        }
    }
}