import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import hudson.util.Secret
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl

String credentials_id = 'github-token'

boolean modified_creds = false
Map system_creds = SystemCredentialsProvider.instance.domainCredentialsMap
Domain domain = system_creds.keySet().find { it.name == null }

if(!(system_creds[domain].find { it.id == credentials_id })) {
    StringCredentialsImpl github_token = new StringCredentialsImpl(CredentialsScope.GLOBAL, credentials_id, "${credentials_id} credentials".toString(), Secret.fromString(gh_token))
    if(system_creds[domain]) {
        //other credentials exist so should only append
        system_creds[domain] << github_token
    }
    else {
        system_creds[domain] = [github_token]
    }
    SystemCredentialsProvider.instance.setDomainCredentialsMap(system_creds)
    SystemCredentialsProvider.instance.save()
    println "${credentials_id} credentials configured."
}
else {
    println "Nothing changed.  ${credentials_id} credentials already configured."
}
