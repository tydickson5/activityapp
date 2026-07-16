import Foundation
import SwiftUI
internal import Combine
internal import PostgREST
import Supabase

@MainActor
final class GroupsHandler: ObservableObject {
    
    @Published var groups: [Group] = []
    @Published var selectedGroup: String? = "6ce9c8f8-2ff2-4f12-8f74-19671fcfb265"
    @Published var creatingGroup: Bool = false
    
    private var memberships: [GroupMember] = []
    
        
    func loadGroups(user: AppUser) async -> String?{
        //original fetch
        await fetchMemberships(userId: user.id)
        await fetchGroups(userId: user.id)
    
        
        selectedGroup = user.selected_group

        return selectedGroup
        
    }
    
    func fetchGroupName(groupId: String) -> String?{
        for group in groups {
            if(group.id == groupId){
                return group.name
            }
        }
        return "Loading..."
    }
    
    
    func fetchGroups(userId: String) async {
        do {
            groups = []
            
            for membership in memberships {
                
                let fetched: [Group] = try await SupabaseHandler.client
                    .from("groups")
                    .select()
                    .eq("id", value: membership.group_id)
                    .execute()
                    .value
                
                self.groups.append(contentsOf: fetched)
            }
        } catch {
            print("Failed to fetch groups:", error)
        }
    }
    
    func fetchMemberships(userId: String) async{
        do {
            memberships = []
            let fetched: [GroupMember] = try await SupabaseHandler.client
                .from("group_memberships")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            self.memberships = fetched
        } catch {
            print(error)
        }
    }
    
    func updatedSelectedGroup(userId: String, groupId: String) async{
        do{
            print(userId)
            print(groupId)
            _ = try await SupabaseHandler.client
                .from("profiles").update(["selected_group": groupId])
                .eq("id", value: userId)
                .execute()
            
            
            
        } catch {
            print(error)
        }
    }
    
    func createGroup(userId: String, name: String)async ->String? {
        self.creatingGroup
        if(name == ""){
            ToastManager.shared.error("Add your group name")
            return nil
        }
        do {
            var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/groups/create")!)
            
            
            
            request.httpMethod = "POST"
            
            let token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization")
            
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            let body: [String: Any] = [
                "userId": userId,
                "name": name
            ]
            
            request.httpBody =
                try? JSONSerialization.data(
                    withJSONObject: body
                )


            let (data, _) =
                try await URLSession.shared.data(
                    for: request
                )

            print(String(
                data: data,
                encoding: .utf8
            ) ?? "")
            let membership = try JSONDecoder().decode(GroupMember.self, from: data)
            self.memberships.append(membership)
            await self.fetchGroups(userId: userId)
            //update selected  group
            print(membership.group_id)
            ToastManager.shared.success("Group created successfully")
            await self.updatedSelectedGroup(userId: userId, groupId: membership.group_id)
            self.selectedGroup = membership.group_id
            self.creatingGroup = false
            return membership.group_id

                
            
        } catch {
            print(error)
            self.creatingGroup = false
            ToastManager.shared.error("Group creation failed")
            return nil
        }
           
            
            
        
    }
    
    func joinGroup(userId: String, groupId: String) async -> String?{
        do {
            var request = URLRequest(url: URL(string: "\(SupabaseHandler.backendURL)/groups/join")!)
            
            request.httpMethod = "POST"
            
            let token = try await SupabaseHandler.client.auth.session.accessToken
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization")
            
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type")
                
            let body: [String: Any] = [
                "userId": userId,
                "groupId": groupId
            ]
            
            request.httpBody =
            try? JSONSerialization.data(
                withJSONObject: body
                , options: .fragmentsAllowed)
            

            let (data, response) =
                try await URLSession.shared.data(
                    for: request
                )

            print(String(
                data: data,
                encoding: .utf8
            ) ?? "")
            let membership = try JSONDecoder().decode(GroupMember.self, from: data)
            await self.fetchMemberships(userId: userId)
            
            await self.fetchGroups(userId: userId)
            
            await self.updatedSelectedGroup(userId: userId, groupId: membership.group_id)
            self.selectedGroup = membership.group_id
            
            ToastManager.shared.success("Success")
            return membership.group_id
                    

            
        } catch{
            print(error)
            ToastManager.shared.error("Join group failed")
            return ""
        }
    }
    
    func getGroupMembers(group: Group) async -> [AppUser] {
        do{
            
            let fetchedMembers: [GroupMember] = try await SupabaseHandler.client.from("group_memberships").select().eq("group_id", value: group.id)
                .execute()
                .value
            
            var members: [AppUser] = []
            for fetchedMember in fetchedMembers{
                let user: AppUser = try await SupabaseHandler.client.from("profiles").select().eq("id", value: fetchedMember.user_id).single().execute().value
                members.append(user)
                
            }
            
            return members
        } catch{
            print(error)
            return []
        }
    }
}
