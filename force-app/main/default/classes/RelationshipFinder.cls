/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-30-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RelationshipFinder {
    /**
     * Finds the shortest relationship path from a child sObject to a parent sObject.
     *
     * @param sObject1Id The Id of the child sObject.
     * @param sObject2Id The Id of the parent sObject.
     * @return The shortest relationship path as a String, or null if no path is found.
     */
    public static String getShortestRelationshipPath(Id sObject1Id, Id sObject2Id) {
        if (sObject1Id == null || sObject2Id == null) {
            return null;
        }

        // Get sObject types from IDs
        String childType = sObject1Id.getSObjectType().getDescribe().getName();
        String parentType = sObject2Id.getSObjectType().getDescribe().getName();

        // Avoid unnecessary processing if the same type is passed
        if (childType == parentType) {
            return null;
        }

        // Use a breadth-first search (BFS) to find the shortest path
        Map<String, String> visited = new Map<String, String>();
        Queue<PathNode> queue = new Queue<PathNode>();

        // Start with the child sObject
        queue.add(new PathNode(childType, ''));

        while (!queue.isEmpty()) {
            PathNode current = queue.poll();
            Schema.DescribeSObjectResult currentDescribe = Schema.getGlobalDescribe().get(current.sObjectType).getDescribe();

            // Traverse fields for parent relationships (Reference Fields)
            for (Schema.SObjectField field : currentDescribe.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                    List<String> referenceTo = fieldDescribe.getReferenceTo();

                    for (String referencedParentType : referenceTo) {
                        String fieldPath = current.path == '' ? fieldDescribe.getName() : current.path + '.' + fieldDescribe.getName();

                        if (referencedParentType == parentType) {
                            return fieldPath; // Found the shortest path
                        }

                        if (!visited.containsKey(referencedParentType)) {
                            visited.put(referencedParentType, fieldPath);
                            queue.add(new PathNode(referencedParentType, fieldPath));
                        }
                    }
                }
            }

            // Traverse child relationships for completeness (though we focus on parent traversal)
            for (Schema.ChildRelationship childRel : currentDescribe.getChildRelationships()) {
                String childRelType = childRel.getChildSObject();
                String childRelPath = current.path == '' ? childRel.getField() : current.path + '.' + childRel.getField();

                if (childRelType == parentType) {
                    return childRelPath; // Found the shortest path
                }

                if (!visited.containsKey(childRelType)) {
                    visited.put(childRelType, childRelPath);
                    queue.add(new PathNode(childRelType, childRelPath));
                }
            }
        }

        // No relationship path found
        return null;
    }

    // Helper class to manage BFS nodes
    private class PathNode {
        public String sObjectType;
        public String path;

        public PathNode(String sObjectType, String path) {
            this.sObjectType = sObjectType;
            this.path = path;
        }
    }
}
