import { createContext, useState, useEffect, useContext } from "react";
import Cookies from "universal-cookie";

type AuthContextType = {
    isAuthenticated: boolean;
    setIsAuthenticated: (isAuthenticated: boolean) => void;
    loading: boolean;
};

const cookies = new Cookies();
const AuthContext = createContext<AuthContextType | undefined>(undefined);

function AuthProvider({ children }: { children: React.ReactNode }) {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const cookieValue = cookies.get("is_authenticated");
        const hasAuth = cookieValue === "1" || cookieValue === 1;
        setIsAuthenticated(hasAuth);
        setLoading(false);
    }, []);

    return (
        <AuthContext.Provider value={{ isAuthenticated, setIsAuthenticated, loading }}>
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