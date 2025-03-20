import { createContext, useState, useEffect, useContext } from "react";

type AuthContextType = {
    isAuthenticated: boolean;
    setIsAuthenticated: (isAuthenticated: boolean) => void;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

function AuthProvider({ children }: { children: React.ReactNode }) {
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    useEffect(() => {
        const token = sessionStorage.getItem("token");

        if (!token) {
            setIsAuthenticated(false);
        } else {
            setIsAuthenticated(true);
        }
    }, []);

    return (
        <AuthContext.Provider value={{ isAuthenticated, setIsAuthenticated }}>
            {children}
        </AuthContext.Provider>
    )
}

// Custom hook to use the auth context
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};

export { AuthProvider };
export default AuthContext;