import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) var context
    // Query for active notes (sorted by newest)
    @Query(filter: #Predicate<NoteItem> { !$0.isDeleted }, sort: \NoteItem.createdAt, order: .reverse) var activeNotes: [NoteItem]
    // Query for deleted notes
    @Query(filter: #Predicate<NoteItem> { $0.isDeleted }, sort: \NoteItem.createdAt, order: .reverse) var deletedNotes: [NoteItem]
    
    @State private var showingTrash = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("MY NOTES").font(.caption).foregroundStyle(.gray)) {
                    ForEach(activeNotes) { note in
                        NavigationLink(destination: EditorView(note: note)) {
                            VStack(alignment: .leading) {
                                Text(note.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        // Soft Delete: Move to trash
                        for index in indexSet {
                            activeNotes[index].isDeleted = true
                        }
                    }
                }
                
                Section {
                    Button(action: { showingTrash.toggle() }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Recently Deleted (\(deletedNotes.count))")
                        }
                        .foregroundStyle(.red.opacity(0.8))
                    }
                }
            }
            .navigationTitle("JustNotes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: createNote) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingTrash) {
                TrashView() // The Trash Folder
            }
        }
    }
    
    func createNote() {
        let newNote = NoteItem()
        context.insert(newNote) // Add to database
    }
}

// Sub-view for the Trash Can
struct TrashView: View {
    @Environment(\.modelContext) var context
    @Query(filter: #Predicate<NoteItem> { $0.isDeleted }) var deletedNotes: [NoteItem]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(deletedNotes) { note in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(note.title).strikethrough()
                            Text("Deleted").font(.caption).foregroundStyle(.red)
                        }
                        Spacer()
                        // Restore Button
                        Button("Recover") {
                            note.isDeleted = false
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                }
                .onDelete { indexSet in
                    // Hard Delete: Gone forever
                    for index in indexSet {
                        context.delete(deletedNotes[index])
                    }
                }
            }
            .navigationTitle("Trash")
        }
    }
}