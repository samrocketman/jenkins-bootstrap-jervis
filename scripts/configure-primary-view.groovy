/*
    Created by Sam Gleske (https://github.com/samrocketman/)
    Sets the primary view of Jenkins.
 */
Jenkins.instance.setPrimaryView(Jenkins.instance.getView('Welcome'))
println 'Set primary view to Welcome.'
