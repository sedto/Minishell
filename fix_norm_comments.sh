#!/bin/bash

# Script pour supprimer les commentaires non-conformes à la norme 42
# Garde seulement les headers 42 standard

fix_file() {
    local file="$1"
    echo "Fixing comments in: $file"
    
    # Sauvegarde temporaire
    cp "$file" "$file.bak"
    
    # Supprimer les commentaires /* ... */ qui ne sont pas le header 42
    # Le header 42 se termine toujours par la ligne avec "/* ************************************************************************** */"
    # On garde les 12 premières lignes (header 42 standard) et on supprime le reste des commentaires
    
    # Utilise sed pour supprimer les commentaires après le header
    sed -i '
    # Skip les 12 premières lignes (header 42)
    1,12b skip
    
    # Pour les autres lignes, supprimer les commentaires
    s|/\*.*\*/||g
    /^[[:space:]]*\/\*/,/\*\// {
        /^[[:space:]]*\/\*/ d
        /\*\// d
        /^[[:space:]]*\*/ d
    }
    
    :skip
    ' "$file"
    
    # Nettoyer les lignes vides multiples après les commentaires supprimés
    sed -i '/^[[:space:]]*$/N;/^\n$/d' "$file"
}

# Fonction pour traiter un dossier récursivement
process_directory() {
    local dir="$1"
    echo "Processing directory: $dir"
    
    find "$dir" -name "*.c" -type f | while read -r file; do
        fix_file "$file"
    done
}

# Usage
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_or_file>"
    echo "Example: $0 parsing/"
    exit 1
fi

if [ -d "$1" ]; then
    process_directory "$1"
elif [ -f "$1" ]; then
    fix_file "$1"
else
    echo "Error: $1 is not a valid file or directory"
    exit 1
fi

echo "Comment cleanup completed!"