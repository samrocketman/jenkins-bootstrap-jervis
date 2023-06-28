script_security_settings = [
    approvedSignatures: [
        // Uncomment to use Jervis built-in cryptography for secrets.  It is
        // recommended to use an external secrets manager such as Hashicorp
        // Vault.  This feature pre-dates Vault and is kept around for
        // compatibility and simpler implementations of Jenkins using Jervis.

        // 'method net.gleske.jervis.lang.LifecycleGenerator setPrivateKey',
        // 'method net.gleske.jervis.lang.LifecycleGenerator decryptSecrets',
        // 'method net.gleske.jervis.lang.PipelineGenerator getSecretPairsEnv',
        'field net.gleske.jervis.lang.LifecycleGenerator jervis_yaml',
        'field net.gleske.jervis.lang.PipelineGenerator generator',
        'method net.gleske.jervis.lang.LifecycleGenerator generateAll',
        'method net.gleske.jervis.lang.LifecycleGenerator generateSection',
        'method net.gleske.jervis.lang.LifecycleGenerator generateToolchainSection',
        'method net.gleske.jervis.lang.LifecycleGenerator getBranchRegexString',
        'method net.gleske.jervis.lang.LifecycleGenerator getFilteredBranchesList',
        'method net.gleske.jervis.lang.LifecycleGenerator getFullBranchRegexStringList',
        'method net.gleske.jervis.lang.LifecycleGenerator getJenkinsfile',
        'method net.gleske.jervis.lang.LifecycleGenerator getLabels',
        'method net.gleske.jervis.lang.LifecycleGenerator getMatrix_fullName_by_friendly',
        'method net.gleske.jervis.lang.LifecycleGenerator hasRegexFilter',
        'method net.gleske.jervis.lang.LifecycleGenerator isFilteredByRegex',
        'method net.gleske.jervis.lang.LifecycleGenerator isGenerateBranch',
        'method net.gleske.jervis.lang.LifecycleGenerator isMatrixBuild',
        'method net.gleske.jervis.lang.LifecycleGenerator isPipelineJob',
        'method net.gleske.jervis.lang.LifecycleGenerator isRestricted',
        'method net.gleske.jervis.lang.LifecycleGenerator isSupportedPlatform',
        'method net.gleske.jervis.lang.LifecycleGenerator loadLifecycles',
        'method net.gleske.jervis.lang.LifecycleGenerator loadLifecyclesString',
        'method net.gleske.jervis.lang.LifecycleGenerator loadPlatforms',
        'method net.gleske.jervis.lang.LifecycleGenerator loadPlatformsString',
        'method net.gleske.jervis.lang.LifecycleGenerator loadToolchains',
        'method net.gleske.jervis.lang.LifecycleGenerator loadToolchainsString',
        'method net.gleske.jervis.lang.LifecycleGenerator loadYamlString',
        'method net.gleske.jervis.lang.LifecycleGenerator matrixExcludeFilter',
        'method net.gleske.jervis.lang.LifecycleGenerator matrixGetAxisValue',
        'method net.gleske.jervis.lang.LifecycleGenerator preloadYamlString',
        'method net.gleske.jervis.lang.LifecycleGenerator setFolder_listing',
        'method net.gleske.jervis.lang.LifecycleGenerator setLabel_stability',
        'method net.gleske.jervis.lang.LifecycleGenerator setLabel_sudo',
        'method net.gleske.jervis.lang.PipelineGenerator getBuildableMatrixAxes',
        'method net.gleske.jervis.lang.PipelineGenerator getDefaultToolchainsEnvironment',
        'method net.gleske.jervis.lang.PipelineGenerator getDefaultToolchainsScript',
        'method net.gleske.jervis.lang.PipelineGenerator getPublishable',
        'method net.gleske.jervis.lang.PipelineGenerator getPublishableItems',
        'method net.gleske.jervis.lang.PipelineGenerator getStashMap',
        'method net.gleske.jervis.lang.PipelineGenerator setStashmap_preprocessor',
        'staticMethod java.lang.Float parseFloat java.lang.String',
        'staticMethod net.gleske.jervis.lang.LifecycleGenerator isInstanceFromList',
        'staticMethod net.gleske.jervis.tools.YamlOperator getObjectValue',
        'staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getCount java.util.regex.Matcher'
    ]
]
